
-- 危险函数, 会污染调用环境, 请小心使用
function _set_upvalue_by_name(name, value, fun)
	-- if _sys.reloading then
	-- 	return
	-- end

	fun = fun or 3
	local info = debug.getinfo(fun, "f")
	local i = 1
	while true do 
		local upname, upvalue = debug.getupvalue(info.func, i)
		if not upname then
			break
		end
		if upname == '_ENV' then
			if _sys.reloading then
				upvalue[name] = value
				break
			end
			if upvalue[name] and upvalue[name] ~= value then
				error(string.format('upvalue [%s] already exist.', name))
			end

			upvalue[name] = value
			break
		end
		i = i + 1
	end
end

-- 危险函数, 会污染调用环境, 请小心使用
function _set_global(name, value)
	if _sys.reloading then
		_G[name] = value
		return
	end

	if _G[name] ~= nil then
		error(string.format('global variable [%s] already exist!', name))
	end
	_G[name] = value
end