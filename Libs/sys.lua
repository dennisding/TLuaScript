if _ENV._sys == nil then
	_sys = {}
	_sys.root = _text('')
	_sys.paths = {_text('')}
	_sys.suffix = _text('.lua')
	_sys.module_suffix = _text('.lum')
	_sys.loaded = {} -- use for require
	_sys.modules = {} -- use for _import
	_sys.read_file = _cpp_read_file
	_sys.reloading = false
	_sys.reload_table = function(name, old, new) end  -- do nothing, update by reload.lua
	_sys.search_file = nil -- setup later
	_sys.cpp_objects = {} -- {cpp_obj:lua_obj}
	_sys.vtables = {} -- {cpp_type_name: vtable}
	_sys.cpp_funs = {}
	_sys.texts = {}
end

-- modify the require
local function _format_args(...)
	local t = {}
	for k, v in ipairs{...} do
		t[k] = towstring(v)
	end
	return table.concat(t, _text('    '))
end

-- redefined in Libs/log.lua
function print(...)
	_cpp_log(1, _format_args(...))
end

-- redefined in Libs/log.lua
function warning(...)
	_cpp_log(2, _format_args(...))
end
-- to utf16 string
function towstring(obj)
	if type(obj) == 'string' then
		return obj
	end

	return _cpp_utf8_to_utf16(tostring(obj))
end

utf8_to_utf16 = _cpp_utf8_to_utf16
utf16_to_utf8 = _cpp_utf16_to_utf8

-- modify the default behavior
function require(name)
	local module = _sys.loaded[name]
	
	if module ~= nil then
		return module
	end

	module = {}
	module._name = name
	module._loaded = false
	_sys.loaded[name] = module


	local file_name = utf8_to_utf16(name) .. _sys.suffix
	local content = _sys.search_file(file_name)

	local chunk, msg = load(content, utf16_to_utf8(file_name), 'bt')
	if not chunk then
		warning(utf8_to_utf16(msg))
	end

	chunk()
	module._file_name = file_name
	module._loaded = true
end

function _lua_dofile(file_name, display_name, env)
	env = env or _ENV
	local content = _cpp_read_file(file_name)

	if content == nil then
		return nil
	end

	local chunk, msg = load(content, display_name, 'bt', env)
	if not chunk then
		warning(utf8_to_utf16(msg))
	end

	chunk()
	return {}
end

function _sys.search_file(name)
	for k, path in ipairs(_sys.paths) do
		local file_name = _sys.root .. path .. name
		local content = _sys.read_file(file_name)
		if content ~= nil then
			return content
		end
	end

	return nil
end

function _init_sys(root, dirs)
	_sys.root = root
	_sys.paths = dirs
end
