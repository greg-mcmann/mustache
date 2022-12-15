--[[
Copyright 2022 Greg McMann

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
--]]

-- Determine if a value is "truthy"

function truthy(value)
  if type(value) == 'nil' then
    return false
  elseif type(value) == 'boolean' then
    return value
  elseif type(value) == 'string' then
    return #value > 0
  elseif type(value) == 'table' then
    return next(value) ~= null
  else
    return true
  end
end

-- Escape special characters in HTML text

function escapeHtml(text)
  return text:gsub('.', {
    ['&'] = '&amp;',
    ['<'] = '&lt;',
    ['>'] = '&gt;',
    ['"'] = '&quot;',
    ["'"] = '&#x27;'
  })
end

-- Escape special characters in a Lua pattern

function escapePattern(text)
  return text:gsub('.', {
    ["^"] = "%^";
    ["$"] = "%$";
    ["("] = "%(";
    [")"] = "%)";
    ["%"] = "%%";
    ["."] = "%.";
    ["["] = "%[";
    ["]"] = "%]";
    ["*"] = "%*";
    ["+"] = "%+";
    ["-"] = "%-";
    ["?"] = "%?";
  })
end

-- Read the next line from a string

local function lines(text)
  local start = 1
  return function()
    local x = start
    local y = text:find('\n', start)
    if y then
      start = y + 1
      return text:sub(x, y)
    elseif x <= #text then
      start = #text + 1
      return text:sub(x)
    end
  end
end

-- Indent each line within a block of text

local function indent(text, space)
  local result = {}
  for line in lines(text) do
    table.insert(result, space .. line)
  end
  return table.concat(result)
end

-- Search for a value in a context stack using a dotted name

function search(stack, name)
  local keys = {}
  for key in name:gmatch('[^%.]+') do
    table.insert(keys, key)
  end
  for index = #stack, 1, -1 do
    local context = stack[index]
    if #keys == 0 or (#keys > 0 and type(context) == 'table' and context[keys[1]] ~= nil) then
      for _, key in ipairs(keys) do
        if type(context) == 'table' then
          context = context[key]
        else
          context = nil
        end
      end
      return context
    end
  end
end

-- Read the next token from a template string

local function scan(template, otag, ctag, start)
  local content = template:match('^(.-)' .. otag, start) or template:sub(start)
  if #content > 0 then
    local patterns = {
      { name = 'newline', pattern = '^\n' },
      { name = 'space', pattern = '^[ \t\r\v\f]+' },
      { name = 'word', pattern = '^[^ \t\r\v\f\n]+' }
    }
    for index, pattern in ipairs(patterns) do
      local match = content:match(pattern.pattern)
      if match then
        return {
          name = pattern.name,
          value = match,
          advance = #match
        }
      end
    end
  else
    local tags = {
      { name = 'comment', open = '!', close = '' },
      { name = 'section', open = '#', close = '' },
      { name = 'inverse', open = '^', close = '' },
      { name = 'close',   open = '%/', close = '' },
      { name = 'partial', open = '>', close = '' },
      { name = 'nescape', open = '&', close = '' },
      { name = 'nescape', open = '{', close = '}' },
      { name = 'delimit', open = '=', close = '=' },
      { name = 'escape',  open = '', close = '' }
    }
    for index, tag in ipairs(tags) do
      local pattern = '^' .. otag .. tag.open .. '%s*(.-)%s*' .. tag.close .. ctag
      local i, j, capture = template:find(pattern, start)
      if capture then
        return {
          name = tag.name,
          value = capture,
          advance = j - i + 1
        }
      end
    end
  end
end

-- Trim space around standalone tokens

local function trim(tokens)

  local istext = {
    ['escape'] = true,
    ['nescape'] = true,
    ['word'] = true
  }

  local iscontrol = {
    ['close'] = true,
    ['comment'] = true,
    ['delimit'] = true,
    ['inverse'] = true,
    ['partial'] = true,
    ['section'] = true
  }

  local text = {}
  local control = {}
  local line = {}
  local result = {}
  for index, token in ipairs(tokens) do
    token.indent = ''
    table.insert(line, token)
    if istext[token.name] then
      table.insert(text, token)
    elseif iscontrol[token.name] then
      table.insert(control, token)
    end
    if token.name == 'newline' or index == #tokens then
      if #text == 0 and #control == 1 then
        if #line > 1 and line[2].name == 'partial' and line[1].name == 'space' then
          line[2].indent = line[1].value
        end
        table.insert(result, control[1])
      else
        for i = 1, #line do
          result[#result + 1] = line[i]
        end
      end
      text = {}
      control = {}
      line = {}
    end
  end
  return result
end

-- Converts a template into a stream of tokens

local function lex(template)
  local tokens = {}
  local start = 1
  local otag = escapePattern('{{')
  local ctag = escapePattern('}}')
  repeat
    local token = scan(template, otag, ctag, start)
    if token then
      -- print(token.name, token.value, start)
      start = start + token.advance
      table.insert(tokens, token)
      if token.name == 'delimit' then
        otag, ctag = string.match(tostring(token.value), '^%s*(%S+)%s+(%S+)%s*$')
        if not otag or not ctag then
          error('Delimiter change requires two sequences separated by whitespace')
        else
          otag = escapePattern(otag)
          ctag = escapePattern(ctag)
        end
      end
    end
  until not token
  return tokens
end

-- Parse tokens into a hierarchy of sections

local function parse(tokens)
  local stack = {
    { name = 'root', children = {} }
  }
  for index, token in ipairs(tokens) do
    token.children = {}
    if token.name == 'close' then
      local top = table.remove(stack)
      if top.name == 'root' then
        error('Section "' .. token.value .. '" must have an opening tag')
      elseif top.value ~= token.value then
        error('Section "' .. top.value .. '" must be closed before closing "' .. token.value .. '"')
      end
    end
    table.insert(stack[#stack].children, token)
    if token.name == 'section' then
      table.insert(stack, token)
    elseif token.name == 'inverse' then
      table.insert(stack, token)
    end
  end
  if #stack > 1 then
    error('Section "' .. stack[#stack].value .. '" must have a closing tag')
  end
  return stack[1].children
end

-- Compile a template

local function compile(template, data, partials)

  local stack = { data }

  function process(tokens)
    local results = {}
    for index, token in ipairs(tokens) do
      local output = ''
      if token.name == 'word' then
        output = token.value
      elseif token.name == 'space' then
        output = token.value
      elseif token.name == 'newline' then
        output = token.value
      elseif token.name == 'escape' then
        output = escapeHtml(tostring(search(stack, token.value) or ''))
      elseif token.name == 'nescape' then
        output = tostring(search(stack, token.value) or '')
      elseif token.name == 'section' then
        local result = search(stack, token.value)
        table.insert(stack, result or false)
        if truthy(result) then
          if type(result) == 'table' and #result > 0 then
            for i = 1, #result do
              table.insert(stack, result[i])
              output = output .. process(token.children)
              table.remove(stack)
            end
          else
            output = output .. process(token.children)
          end
        end
      elseif token.name == 'inverse' then
        local result = search(stack, token.value)
        table.insert(stack, result or false)
        if not truthy(result) then
          output = output .. process(token.children)
        end
      elseif token.name == 'close' then
        table.remove(stack)
      elseif token.name == 'partial' then
        local partial = partials[token.value]
        if partial then
          local indented = indent(partial, token.indent)
          output = process(parse(trim(lex(indented))))
        end
      end
      table.insert(results, output)
    end
    return table.concat(results)
  end

  return process(parse(trim(lex(template))))

end

return {
  ['lex'] = lex,
  ['parse'] = parse,
  ['compile'] = compile,
}
