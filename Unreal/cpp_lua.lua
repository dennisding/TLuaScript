
local actor = silent_import('actor')
local component = silent_import('component')
local object = silent_import('object')

-- 在bind_object之前, 只能单向操作, 
-- 即只能通过lua操作c++对象.
-- 这个对象通过c++调用lua函数的参数
-- 或是lua调用c++函数的返回值传递给lua
function _lua_bind_obj(cobject, ctype)
	if _sys.cpp_objects[cobject] ~= nil then
		return _sys.cpp_objects[cobject]
	end

	local instance = actor.new_proxy(cobject, ctype)
	_sys.cpp_objects[cobject] = instance
	instance:_call_init()

	_world.player = instance
	return instance
end

function _lua_get_obj(cobject, ctype)
	local object = _sys.cpp_objects[cobject]
	if object ~= nil then
		return object
	end
	if ctype == nil then
		ctype = _cpp_object_get_type(cobject)
	end

	return actor.new_proxy(cobject, ctype)
end

function _lua_get_com(cobject, ctype)
	return component.new_component(cobject, ctype)
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

function _lua_tcall(cobject, name, ...)
	local self = _lua_get_obj(cobject)
	local method = self[name]
	if method then
		method(self, ...)
	end
end

local function _get_class(module_name, class_name)
	local module = silent_import(module_name)
	return module[class_name]
end

local function _get_method(callback, context)
	local function _fun(self, ...)
		return callback(rawget(self, '_co'), context, ...)
	end

	return _fun
end

local function _set_method(lua_class, name, method)
--	assert(rawget(lua_class, name) == nil, string.format('method<%s> already exist.', name))

	rawset(lua_class, name, method)
end

function _lua_actor_method(class_name, method_name, callback, context)
	local lua_class = _get_class(class_name, class_name)
	_set_method(lua_class, method_name, _get_method(callback, context))
end

function _lua_component_method(class_name, method_name, callback, context)
	local lua_class = _get_class('Components.' .. class_name, class_name)
	_set_method(lua_class, method_name, _get_method(callback, context))
end
