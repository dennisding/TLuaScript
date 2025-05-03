
function _import(name)
	if _sys.modules[name] ~= nil then
		return _sys.modules[name]
	end

	local file_name = _text(name) .. _sys.module_suffix
	local file_path = file_name
	local content = nil
	for _, path in ipairs(_sys.paths) do
		file_path = _sys.root .. path .. file_name
		content = _sys.read_file(file_path)
		if content ~= nil then
			break
		end
	end

	-- load the module
	local module = {}
	setmetatable(module, {__index = _ENV})
	_sys.modules[name] = module

	local is_ok, chunk = trace_call(load, content, file_path, 'bt', module)
	if not is_ok then
		error(chunk)
	end

	local is_ok, result = trace_call(chunk)
	if not is_ok then
		error(result)
	end

	return module
end
