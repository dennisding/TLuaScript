
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
	local lua_type_name = utf16_to_utf8(lua_type)

	local module = safe_import(lua_type_name)
	-- hook the module
	local lua_class = module[lua_type_name]
	local instance = lua_class:_new_instance()

	-- instance._cpp_obj = obj
	rawset(instance, '_cpp_obj', obj)
	lua_class._cpp_type_id = cpp_type_id
	instance:_call_init()

	_sys.cpp_objects[obj] = instance
end

function _lua_unbind(obj)
	_sys.cpp_objects[obj] = nil
end

function _lua_call_method(obj, name, ...)
--	print(_text('_lua_call_method'), _text(tostring(obj)), _text(tostring(name)), _text(tostring(arg)))
	local instance = _sys.cpp_objects[obj]
	return instance[name](instance, ...)
end

function _lua_silent_call_method(obj, name, ...)
	local instance = _sys.cpp_objects[obj]
	local method = instance[name]
	if method ~= nil then
		return method(instance, ...)
	end
end

local function _set_local_attr(lua_class, lua_attr_name)
	local function _getter(self)
		return rawget(self, lua_attr_name)
	end
	local function _setter(self, value)
		rawset(self, lua_attr_name, value)
	end
	lua_class._vtable[lua_attr_name] = {_getter, _setter}
end

local function _get_attr_info(cpp_type_id, attr_name)
	local lua_attr_name = utf16_to_utf8(attr_name)
	local lua_type_id = utf16_to_utf8(cpp_type_id)
	-- teset code
	local tokens = stringx.split(lua_type_id, '.')
	local class_name = tokens[#tokens]
	local module = safe_import(class_name)
	local lua_class = module[class_name]

	return lua_attr_name, lua_class
end

function _lua_update_vtable_fun(cpp_type_id, attr_name, attr)
	local lua_attr_name, lua_class = _get_attr_info(cpp_type_id, attr_name)

	if attr == 0 then
		-- not a valid cpp attribute
		_set_local_attr(lua_class, lua_attr_name)
		return
	end

	local function _getter(self)
		local function _call_helper(self, ...)
			_cpp_get_attr(self._cpp_obj, attr, ...)
		end

		return _call_helper
	end

	lua_class._vtable[lua_attr_name] = {_getter, _getter}
end

function _lua_update_vtable_attr(cpp_type_id, attr_name, attr)
	local lua_attr_name, lua_class = _get_attr_info(cpp_type_id, attr_name)

	if attr == 0 then
		-- not a valid cpp attribute
		_set_local_attr(lua_class, lua_attr_name)
		return
	end

	local function _getter(self)
		return _cpp_get_attr(self._cpp_obj, attr)
	end

	local function _setter(self, value)
		_cpp_set_attr(self._cpp_obj, attr, value)
	end
	lua_class._vtable[lua_attr_name] = {_getter, _setter}
end

function _update_vtable(class, name)
	_cpp_update_vtable(class._cpp_type_id, utf8_to_utf16(name))
end

function _get_lua_type(type_full_name)
	local tokens = stringx.split(type_full_name, '.')
	local module = safe_import(type_full_name)

	return module[tokens[#tokens]]
end
