
_log = {}
-- log type
_log.display_type = 1
_log.warning_type = 2
_log.error_type = 4

_log.tostring = function(obj)
	if type(obj) == 'string' then
		return obj
	end
	
	return tostring(obj)
end

_log.display = function(msg)
	local text = _log.tostring(msg)
	_cpp_log(_log.display_type, text)
end

_log.warning = function(msg)
	local text = _log.tostring(msg)
	_cpp_log(_log.warning_type, text)
end

_log.error = function(msg)
	local text = _log.tostring(msg)
	_cpp_log(_log.error_type, text)
end

-- replace the default print

