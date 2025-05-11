
local function _gather_method(result, t)
	for name, value in pairs(t) do
		if type(value) == 'function' then
			container = result[name] or {}
			table.insert(container, value)
			result[name] = container
		end
	end
end

local function _build_plugin_method(method_map, overloads, reverses)
	local result = {} -- {name:fun}
	overloads = tablex.to_set(overloads)
	reverses = tablex.to_set(reverses)

	local function _gen_list_method(name, methods)
		if reverses[name] ~= nil then
			tablex.reverse(methods)
		end

		local function _fun(...)
			for _, method in pairs(methods) do
				method(...)
			end
		end

		return _fun
	end

	for name, methods in pairs(method_map) do
		if #methods == 1 then
			result[name] = methods[1]
		elseif overloads[name] == nil then
			error(string.format("invalid overload method:<%s>", name))
		else
			result[name] = _gen_list_method(name, methods)
		end
	end

	return result
end

local function _gen_plugin_method(type, plugins, overloads, reverses)
	local methods = {} -- {name:{method1, method2, method3}}
	_gather_method(methods, type)
	for _, plugin_name in ipairs(plugins) do
		local plugin = safe_import(plugin_name)
		_gather_method(methods, plugin)
	end

	return _build_plugin_method(methods, overloads, reverses)
end

function class(name)
	local _new_class = {_type = name}
	_new_class.__index = _new_class
	_set_upvalue_by_name(name, _new_class)

	local function _new_instance()
		local instance = {}
		setmetatable(instance, _new_class)
		return instance
	end

	local function _call_init(instance, ...)
		local init = _new_class._init
		if init ~= nil then
			init(instance, ...)
		end
		return instance
	end

	local function _new(type, ...)
		local instance = _new_instance()
		_call_init(instance, ...)
		return instance
	end

	local function _index(self, name)
		local attr = rawget(_new_class, name)
		if attr ~= nil then
			return attr
		end

		if _new_class._vtable[name] == nil then
			_update_vtable(_new_class, name)
		end
		return _new_class._vtable[name][1](self)
	end
	
	local function _newindex(self, name, value)
		local attr_info = _new_class._vtable[name]
		if attr_info == nil then
			_update_vtable(_new_class, name)
			attr_info = _new_class._vtable[name]
		end
		if attr_info == nil then
			return rawset(self, name, value)
		end
		return attr_info[2](self, value)
	end

	local function _install_plugins(plugins, overloads, reverses)
		local methods = _gen_plugin_method(_new_class, plugins, overloads, reverses)
		for name, fun in pairs(methods) do
			_new_class[name] = fun
		end
	end

	local function _have_cpp_obj()
		_new_class._vtable = {}
		_new_class.__index = _index
		_new_class.__newindex = _newindex
	end

	local function _set_hint(...)
		local args = {...}
		if tablex.find(args, 'have_cpp_obj') then
			_have_cpp_obj()
		end
	end

	-- class setup
	_new_class._new_instance = _new_instance
	_new_class._call_init = _call_init
	_new_class._install_plugins = _install_plugins
	_new_class._have_cpp_obj = _have_cpp_obj
	_new_class._set_hint = _set_hint

	-- metatable setup
	local metatable = {}
	metatable.__call = _new
	setmetatable(_new_class, metatable)
	return _new_class
end
