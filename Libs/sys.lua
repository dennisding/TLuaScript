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

	local env = _ENV
	if _sys.reloading then
		env = {}
		setmetatable(env, {__index = _ENV})
	end

	local display_name = utf16_to_utf8(name .. _sys.suffix)
	for _, path in ipairs(_sys.paths) do
		local file_name = _sys.root .. path .. name .. _sys.suffix

		local module = dofile(file_name, display_name, env)
		if module ~= nil then
			module._name = name
			module._file_name = file_name
			_sys.loaded[name] = module

			-- 
			if _sys.reloading then
				_sys.reload_table(display_name, _ENV, env)
			end
		end
	end
end

function dofile(file_name, display_name, env)
	env = env or _ENV
	local content = _cpp_read_file(file_name)
	if content == nil then
		return nil
	end

	local chunk, msg = load(content, display_name, 'bt', env)
	if not chunk then
		_log.warning(utf8_to_utf16(msg))
	end

	chunk()
	return {}
end

function _init_sys(root, dirs)
	_sys.root = root
	_sys.paths = dirs
end
