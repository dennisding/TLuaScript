
local actor = silent_import('actor')

-- 在bind_object之前, 只能单向操作, 
-- 即只能通过lua操作c++对象.
-- 这个对象通过c++调用lua函数的参数
-- 或是lua调用c++函数的返回值传递给lua
function _lua_bind_obj(cobject)
	assert(_sys.cpp_objects[cobject] == nil)

	local instance = _lua_get_obj(cobject)
	_sys.cpp_objects[cobject] = instance
	return instance
end

function _lua_get_obj(cobject)
	local instance = _sys.cpp_objects[cobject]
	if instance ~= nil then
		return instance
	end

	local instance = actor.actor_proxy._new_instance()
	
	local ctype = _cpp_object_get_type(cobject)
	rawset(instance, '_co', cobject)
	rawset(instance, '_ct', ctype)
	instance._call_init(instance)

	return instance
end

function _lua_unbind_obj(cpp_obj)
	print(_text('lua_unbind_obj'))
	assert(_sys.cpp_objects[cpp_obj] ~= nil)

	_sys.cpp_objects[cpp_obj] = nil
end

function _lua_call(self, name, ...)
	local method = self[name]
	if method == nil then
		error(string.format('Invalid call from c++[%s:%s]', name))
	end
	return method(self, ...)
	-- local lua_obj = _sys.cpp_objects[cpp_obj]
	-- assert(lua_obj ~= nil)
	-- local method = lua_obj[name]
	-- if method == nil then
	-- 	error(string.format('Invalid call from c++[%s:%s]', lua_obj, name))
	-- end
	-- return method(lua_obj, ...)
end
