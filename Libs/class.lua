
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

	local metatable = {}
	metatable.__call = _new
	metatable._new_instance = _new_instance
	metatable._call_init = _call_init

	setmetatable(_new_class, metatable)
	return _new_class
end
