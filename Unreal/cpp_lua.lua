
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

function _lua_bind_obj(obj, cpp_type)
	print(_text('_lua_bind_obj'), obj, cpp_type)
	local lua_type = utf16_to_utf8(cpp_type)

	local module = silent_import(lua_type)
	-- hook the module
	local lua_class = module[lua_type]
	lua_class.__index = _index
	lua_class.__newindex = _newindex

	local instance = lua_class:_new_instance()
	-- instance._vtable = _get_vtable(cpp_type)
	instance._cpp_obj = obj
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

function _lua_update_vtable()
end

function _update_vtable(class, name)
	local function _setter(self, name, value)
		return rawset(self, name, value)
	end

	local function _getter(self, name)
		return rawget(self, name)
	end

	class._vtable[name] = {_getter, _setter}
end