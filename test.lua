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

local mustache = require "mustache"

local function test(specs)
  for _, path in pairs(specs) do
    print('\n' .. path .. '\n')
    for _, test in ipairs(require(path)) do
      local result = mustache.compile(
        test.template or '',
        test.data or {},
        test.partials or {}
      )
      if result == test.expected then
        print('o : ' .. test.name)
      else
        local replace = {
          ['\t'] = '\\t',
          ['\r'] = '\\r',
          ['\v'] = '\\v',
          ['\f'] = '\\f',
          ['\n'] = '\\n',
        }
        print(
          string.format(
            'x : %s\n\nExpected\n%s\nActual\n%s\n',
            test.name,
            string.gsub(test.expected,'(.)',replace),
            string.gsub(result or '','(.)',replace)
          )
        )
      end
    end
  end
end

test({
  'spec/comments',
  'spec/delimiters',
  'spec/interpolation',
  'spec/sections',
  'spec/inverted',
  'spec/partials',
})
