
if _ENV._sys == nil then
	_sys = {}
	_sys.root = _text('')
	_sys.paths = {_text('')}
	_sys.suffix = _text('.lua')
	_sys.module_suffix = _text('.lum')
	_sys.loaded = {} -- use for require
	_sys.modules = {} -- use for _import
	_sys.read_file = _cpp_read_file
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

	local display_name = utf16_to_utf8(name .. _sys.suffix)
	for _, path in ipairs(_sys.paths) do
		local file_name = _sys.root .. path .. name .. _sys.suffix

		local module = dofile(file_name, display_name)
		if module ~= nil then
			_sys.modules[name] = module
		end
	end
end

function dofile(file_name, display_name)
	local content = _cpp_read_file(file_name)
	if content == nil then
		return nil
	end
	local chunk, msg = load(content, display_name, 'bt')
	if not chunk then
		_log.warning(utf8_to_utf16(msg))
	end
	
	local result = chunk() or {}
	return result
end

function _init_sys(root, dirs)
	_sys.root = root
	_sys.paths = dirs
end