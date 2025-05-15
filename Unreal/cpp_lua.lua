

function _lua_bind_obj(obj)
	print(_text('lua_bind_obj'), _text(tostring(obj)))
	local cpp_obj = rawget(obj, '_co')
	assert(_sys.cpp_objects[cpp_obj] == nil)
	_sys.cpp_objects[cpp_obj] = obj
end

function _lua_unbind_obj(cpp_obj)
	print(_text('lua_unbind_obj'))
	assert(_sys.cpp_objects[cpp_obj] ~= nil)

	_sys.cpp_objects[cpp_obj] = nil
end

function _lua_call(cpp_obj, name, ...)
	local lua_obj = _sys.cpp_objects[cpp_obj]
	assert(lua_obj ~= nil)
	local method = lua_obj[name]
	if method == nil then
		error(string.format('Invalid call from c++[%s:%s]', lua_obj, name))
	end
	return method(lua_obj, ...)
end
