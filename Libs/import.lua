
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

local function _to_set(t)
	local result = {}
	for _, value in ipairs(t) do
		result[value] = true
	end

	return result
end

local function _load_chunk(name, env, hints)
	local name_tokens, file_name = _format_module_name(name)
	local content = _sys.search_file(file_name)

	local chunk, msg = nil, nil
	if hints.silent and content == nil then -- 什么都不用做
	else
		if content == nil then
			error(string.format('invalid module: %s', name))
		end
		chunk, msg = load(content, utf16_to_utf8(file_name), 'bt', env)
		if chunk then
			chunk()
		else
			error(msg)
		end
	end

	return name_tokens, file_name
end

-- 默认import的行为
-- 在当前ENV引入name 或 shortcut, 
-- 
function import(name, shortcut, ...)
	local hints = _to_set({...})

	local module = _sys.modules[name]
	if _sys.reloading then
		-- reload logic
	else
		-- normal logic
		if module then
			if not hints.clean then
				_set_upvalue_by_name(shortcut or module._shortcut, module)
			end
			return module
		end
	end

	-- load the module
	module = module or {}

	setmetatable(module, {__index = _ENV})
	_sys.modules[name] = module

	local old_module = nil
	if _sys.reloading then
		-- reloading 逻辑
		if _sys.reloading[module] ~= nil then
			-- 正在import, 有可能出现循环import的情况
			return module
		end
		-- 设置reloading
		_sys.reloading[module] = true
		old_module = tablex.raw_copy(module)
	end

	local name_tokens, file_name = _load_chunk(name, module, hints)

	module._shortcut = shortcut or name_tokens[#name_tokens]
	module._file_name = file_name

	if not hints.clean then
		_set_upvalue_by_name(module._shortcut, module)
	end

	if _sys.reloading then
		_sys.update_module({'import', name}, old_module, module)
		_sys.reloading[module] = nil
	end
	return module
end

function silent_import(name, shortcut, ...)
	return import(name, shortcut, 'silent', ...)
end

function clean_import(name, shortcut, ...)
	return import(name, shortcut, 'clean', ...)
end

function safe_import(name, shortcut, ...)
	return import(name, shortcut, 'silent', 'clean')
end
