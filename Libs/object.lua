

-- replace this in your cpp code
-- table for c++ object

function _lua_bind_cpp_object(cpp_obj, cpp_type, lua_type)
	assert(_cpp_objects[cpp_obj] == nil)
	
	local module = _import(lua_type)
	local lua_obj = module[lua_type]()

	-- setup the lua_obj
	lua_obj._cpp_object = cpp_obj
	lua_obj._cpp_type = cpp_type

	_cpp_objects[cpp_obj] = lua_obj

	lua_obj:enter_level()
end