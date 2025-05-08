
local function _get_vtable(cpp_type)
	local vtable = _sys.vtables[cpp_type]
	if vtable ~= nil then
		return vtable
	end

	vtable = {}
	_sys.vtables[cpp_type] = vtable
	vtable._cpp_type = cpp_type
	return vtable
end

function _lua_bind_obj(obj, cpp_type_id, lua_type)
	print(_text('_lua_bind_obj'), obj, cpp_type_id, lua_type)
	local lua_type_name = utf16_to_utf8(lua_type)

	local module = silent_import(lua_type_name)
	-- hook the module
	local lua_class = module[lua_type_name]
	local instance = lua_class:_new_instance()
	-- instance._vtable = _get_vtable(cpp_type)
	instance._cpp_obj = obj
	lua_class._cpp_type_id = cpp_type_id
	instance:_call_init()

	_sys.cpp_objects[obj] = instance
end

function _lua_unbind(obj)
	_sys.cpp_objects[obj] = nil
end

function _lua_call_method(obj, name, ...)
	print(_text('_lua_call_method'), _text(name))
	local instance = _sys.cpp_objects[obj]
	return instance[name](instance, ...)
end

function _lua_update_vtable(cpp_type_id, attr_name, gp, getter, sp, setter)
	local lua_attr_name = utf16_to_utf8(attr_name)
	local lua_type_id = utf16_to_utf8(cpp_type_id)
	local function _getter(self, name)
		return _cpp_callback(gp, getter, self, attr_name)
	end

	local function _setter(self, name, value)
		_cpp_callback(sp, setter, self, attr_name, value )
	end

	-- teset code
	local tokens = stringx.split(lua_type_id, '.')
	local class_name = tokens[#tokens]
	local module = silent_import(class_name)
	local lua_class = module[class_name]
	lua_class._vtable[lua_attr_name] = {_getter, _setter}
end

function _update_vtable(class, name)
	_cpp.update_vtable(class._cpp_type_id, utf8_to_utf16(name))
end