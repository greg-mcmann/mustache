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

-- Generate token patterns for a generic for-loop.

local function patterns(otag, ctag)

  otag = string.gsub(otag or '{{', '(%p)', '%%%1')
  ctag = string.gsub(ctag or '}}', '(%p)', '%%%1')

  local table = {
    { token = 'comment',  increment = 'match',   pattern = '^' .. otag .. '!%s*(.-)%s*'  .. ctag },
    { token = 'section',  increment = 'match',   pattern = '^' .. otag .. '#%s*(.-)%s*'  .. ctag },
    { token = 'inverse',  increment = 'match',   pattern = '^' .. otag .. '^%s*(.-)%s*'  .. ctag },
    { token = 'close',    increment = 'match',   pattern = '^' .. otag .. '/%s*(.-)%s*'  .. ctag },
    { token = 'partial',  increment = 'match',   pattern = '^' .. otag .. '>%s*(.-)%s*'  .. ctag },
    { token = 'noescape', increment = 'match',   pattern = '^' .. otag .. '&%s*(.-)%s*'  .. ctag },
    { token = 'noescape', increment = 'match',   pattern = '^' .. otag .. '{%s*(.-)%s*}' .. ctag },
    { token = 'delimit',  increment = 'match',   pattern = '^' .. otag .. '=%s*(.+)%s*=' .. ctag },
    { token = 'escape',   increment = 'match',   pattern = '^' .. otag ..  '%s*(.-)%s*'  .. ctag },
    { token = 'newline',  increment = 'capture', pattern = '^(\n)' },
    { token = 'space',    increment = 'capture', pattern = '^([ \t\r\v\f]+)' },
    { token = 'word',     increment = 'capture', pattern = '^([^ \t\r\v\f\n]-)' .. otag },
    { token = 'word',     increment = 'capture', pattern = '^([^ \t\r\v\f\n]+)' }
  }

  local i = 0
  return function()
    i = i + 1
    return table[i]
  end
end

-- Generate tokens from a mustache template for a generic for-loop.

local function scan(template)

  local otag, ctag = '{{', '}}'
  local start = 1
  
  return function ()
    for entry in patterns(otag, ctag) do
      local i, j, capture = string.find(template, entry.pattern, start)
      if capture and #capture > 0 then
        if entry.token == 'delimit' then
          otag, ctag = string.match(capture, '^%s*(%S+)%s+(%S+)%s*$')
          if not otag or not ctag then
            error('Delimiter change requires two sequences separated by whitespace')
          end
        end
        if entry.increment == 'capture' then
          start = start + #capture
        else
          start = start + (j - i + 1)
        end
        return {
          ['name'] = entry.token,
          ['value'] = capture,
          ['indent'] = '',
          ['children'] = {}
        }
      end
    end
    return nil
  end
end

-- Trim space around standalone mustache tags.

local function trim(tokens)

  local trimmed = {}
  local line = {}
  local tags = {}
  local ntext = 0
  local indent = ''

  for index, token in ipairs(tokens) do

    table.insert(line, token)

    if token.name == 'word' then
      ntext = ntext + 1
    elseif token.name == 'escape' or token.name == 'noescape' then
      ntext = ntext + 1
    elseif token.name == 'space' then
      indent = #line == 1 and token.value or ''
    elseif token.name ~= 'newline' then
      table.insert(tags, token)
    end

    if token.name == 'newline' or index == #tokens then
      if #tags == 1 and ntext == 0 then
        if tags[1].name == 'partial' and #indent > 0 then
          tags[1].indent = indent
          table.insert(trimmed, line[1])
        end
        table.insert(trimmed, tags[1])
      else
        for i = 1, #line do
          table.insert(trimmed, line[i])
        end
      end
      line = {}
      tags = {}
      ntext = 0
      indent = ''
    end
  end
  return trimmed
end

-- Nest a sequence of tokens into sections.

local function nest(tokens)

  local stack = {}
  local parent = {
    name = nil,
    value = nil,
    children = {}
  }

  for _, token in ipairs(tokens) do
    if token.name == 'close' then
      if token.value == parent.value then
        parent = table.remove(stack)
      else
        error('Unexpected section close tag "' .. token.value .. '"')
      end
    end
    table.insert(parent.children, token)
    if token.name == 'section' or token.name == 'inverse' then
      table.insert(stack, parent)
      parent = token
    end
  end

  if #stack > 0 then
    error('Section "' .. parent.value .. '" is not closed')
  end

  return parent.children

end

-- Convert a mustache template into tokens.

local function parse(template)
  local tokens = {}
  for token in scan(template) do
    table.insert(tokens, token)
  end
  return nest(trim(tokens))
end

-- Search for a named value within a context stack.

local function lookup(stack, name)
  for i = #stack, 1, -1 do
    local value = stack[i]
    local hasMatch = false
    for key in string.gmatch(name, '([^%.]+)') do
      if type(value) == 'table' then
        value = value[key]
        hasMatch = hasMatch or value ~= nil
      else
        value = nil
      end
      if hasMatch and value == nil then
        return nil
      end
    end
    if value ~= nil then
      return value
    end
  end
  return nil
end

-- Render a parsed template into a string.

local function render(tokens, stack, partials, indent)

  local result = ''

  for index, token in ipairs(tokens) do
    if token.name == 'partial' then
      if partials[token.value] then
        result = result .. render(partials[token.value], stack, partials, indent .. token.indent)
      end
    elseif token.name == 'section' then
      local value = lookup(stack, token.value)
      table.insert(stack, value)
      if type(value) == 'table' then
        if #value > 0 then
          for i = 1, #value do
            table.insert(stack, value[i])
            result = result .. render(token.children, stack, partials, indent)
            table.remove(stack)
          end
        elseif next(value) then
          result = result .. render(token.children, stack, partials, indent)
        end
      elseif value then
        result = result .. render(token.children, stack, partials, indent)
      end
    elseif token.name == 'inverse' then
      local value = lookup(stack, token.value)
      table.insert(stack, value)
      if not value or (type(value) == 'table' and not next(value)) then
        result = result .. render(token.children, stack, partials, indent)
      end
    elseif token.name == 'close' then
      table.remove(stack)
    elseif token.name == 'escape' then
      local value = lookup(stack, token.value)
      if type(value) == 'string' then
        result = result .. string.gsub(value, '([&<>"\'])', {
          ['&'] = '&amp;',
          ['<'] = '&lt;',
          ['>'] = '&gt;',
          ['"'] = '&quot;',
          ["'"] = '&#x27;'
        })
      elseif type(value) == 'number' then
        result = result .. tostring(value)
      end
    elseif token.name == 'noescape' then
      local value = lookup(stack, token.value)
      if type(value) == 'string' then
        result = result .. value
      elseif type(value) == 'number' then
        result = result .. tostring(value)
      end
    elseif token.name == 'word' or token.name == 'space' then
      result = result .. token.value
    elseif token.name == 'newline' then
      result = result .. token.value .. indent
    end
  end

  return result

end

-- Return a single function for rendering a mustache template.

return function (template, data, partials)
  local templateTokens = parse(template or '')
  local partialTokens = {}
  for name, partial in pairs(partials or {}) do
    partialTokens[name] = parse(partial)
  end
  return render(templateTokens, { data or {} }, partialTokens, '')
end
