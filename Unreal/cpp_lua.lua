
local actor = silent_import('actor')

-- 在bind_object之前, 只能单向操作, 
-- 即只能通过lua操作c++对象.
-- 这个对象通过c++调用lua函数的参数
-- 或是lua调用c++函数的返回值传递给lua
function _lua_bind_obj(cobject)
	if _sys.cpp_objects[cobject] ~= nil then
		return _sys.cpp_objects[cobject]
	end

	local instance = _lua_get_obj(cobject)
	_sys.cpp_objects[cobject] = instance

	_world.player = instance
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
	--instance._call_init(instance)
	if instance._call_init then-- trigger the reset_metatable
	end

	return instance
end

function _lua_get_enum(ctype, value)
	return Enum:_get_enum_value(ctype, value)
end

function _lua_new_struct(ctype)

end

function _lua_unbind_obj(cpp_obj)
	print(_text('lua_unbind_obj'))
	assert(_sys.cpp_objects[cpp_obj] ~= nil)

	_sys.cpp_objects[cpp_obj] = nil
end

function _lua_call(cobject, name, ...)
	local self = _lua_get_obj(cobject)
	local method = self[name]
	if method == nil then
		error(string.format('Invalid call from c++[%s]', tostring(name)))
	end
	return method(self, ...)
end
