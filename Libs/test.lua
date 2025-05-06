
local value = 1356

class('Test')

function Test:_init()
	self.name = 'dennis'
	self.age = 18
end

function Test:say_hello()
	print(_text('say_hello from test reloaded'))
end

function new_obj()
	test_obj = Test()
end

function test_obj_say_hello()
	test_obj:say_hello()
end

function test2()
	print(_text('reload test444'), towstring(value))
end

function test()
	-- _sys.loading and test2()
	print(_text('reload test1'))
	test2()
end