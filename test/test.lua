local mustache = (loadfile '../mustache.lua')()

local function test(specs)
  for _, path in pairs(specs) do
    print('\n' .. path .. '\n')
    for _, test in ipairs(require(path)) do
      local result = mustache(
        test.template or '',
        test.data or {},
        test.partials or {}
      )
      if result == test.expected then
        print('o : ' .. test.name)
      else
        print(
          string.format(
            'x : %s\n\nExpected\n%s\nActual\n%s\n',
            test.name,
            test.expected,
            result
          )
        )
      end
    end
  end
end

test({
  'specs/comments',
  'specs/delimiters',
  'specs/interpolation',
  'specs/sections',
  'specs/inverted',
  'specs/partials',
})
