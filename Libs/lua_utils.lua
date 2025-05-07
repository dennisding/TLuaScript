
function _set_upvalue_by_name(name, value, fun)
	fun = fun or 3
	local info = debug.getinfo(fun, "f")
	local i = 1
	while true do 
		local upname, upvalue = debug.getupvalue(info.func, i)
		if not upname then
			break
		end
		if upname == '_ENV' then
			upvalue[name] = value
			break
		end
		i = i + 1
	end
end
