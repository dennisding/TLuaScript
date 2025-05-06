
-- turn 'Test.test' to {'Test', 'test'}, 'Test/test.lum'
local function _format_module_name(name)
	local tokens = {}

	local index = 1
	local last = 1
	while index ~= nil do
		index = string.find(name, '.', index, true)
		if index == nil then
			table.insert(tokens, string.sub(name, last))
			break
		end

		table.insert(tokens, string.sub(name, last, index - 1))
		index = index + 1 -- skip the .
		last = index
	end

	local file_name = utf8_to_utf16(string.gsub(name, '%.', '/')) .. _sys.module_suffix
	return tokens, file_name
end

function import(name, shortcut, silent)
	local module = _sys.modules[name]
	module = nil
	if module then
		if not silent then
			_set_upvalue_by_name(shortcut or module._shortcut, module)
		end
		return module
	end

	-- load the module
	module = {}
	setmetatable(module, {__index = _ENV})
	_sys.modules[name] = module

	local name_tokens, file_name = _format_module_name(name)
	local content = _sys.search_file(file_name)

	local chunk, msg = load(content, file_name, 'bt', module)
	chunk()

	module._shortcut = shortcut or name_tokens[#name_tokens]
	module._file_name = file_name

	if not silent then
		_set_upvalue_by_name(module._shortcut, module)
	end
	return module
end

function silent_import(name)
	return import(name, nil, true)
end
