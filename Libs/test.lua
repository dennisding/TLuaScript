
local value = 1234

function test2()
    print(_text('reload test2222'), towstring(value))
end

function test()
    -- _sys.loading and test2()
    print(_text('reload test'))
    test2()
end