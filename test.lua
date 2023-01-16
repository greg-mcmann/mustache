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
]]

local mustache = require "mustache"

-- Paths for supported specifications

local paths = {
  'spec/comments',
  'spec/delimiters',
  'spec/interpolation',
  'spec/sections',
  'spec/inverted',
  'spec/partials',
}

-- Display non-printable characters

local function reveal(text)
  return string.gsub(text or '', '(.)', {
    ['\t'] = '\\t',
    ['\r'] = '\\r',
    ['\v'] = '\\v',
    ['\f'] = '\\f',
    ['\n'] = '\\n',
  })
end

-- Run a single mustache test

local function runTest(test)
  local result = mustache.compile(
    test.template or '',
    test.data or {},
    test.partials or {}
  )
  if result == test.expected then
    print('o : ' .. test.name)
  else
    print('x : ' .. test.name)
    print(string.format(
      '\nExpected\n%s\nActual\n%s\n',
      reveal(test.expected),
      reveal(result)
    ))
  end
end

-- Run all mustache tests

local function runAll()
  for _, path in pairs(paths) do
    print('\n' .. path .. '\n')
    local tests = require(path)
    for _, test in ipairs(tests) do
      runTest(test)
    end
  end
end

runAll()
