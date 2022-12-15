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
