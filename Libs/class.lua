
function _class(name)
	local _new_class = {_type = name or "<unknown>"}
	_new_class.__index = _new_class

	local function _new(type, ...)
			local instance = {}
			setmetatable(instance, _new_class)

			local _init = _new_class._init
			if _init ~= nil then
				_init(instance, ...)
			end

			return instance
	end

	setmetatable(_new_class, {__call = _new})
	return _new_class
end
