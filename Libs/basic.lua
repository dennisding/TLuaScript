-- table for c++ function callback
_cpp = {}		-- all cpp function register here
_texts = {}		-- utf8 to utf16 cache
function _register_callback(name, processor, cfun)
	_cpp = _cpp or {}
	local function _imp(...)
		return _cpp_callback(processor, cfun, ...)
	end
	_cpp[name] = _imp
end

function _text(str)
	local text = _texts[str]
	if text ~= nil then
		return text
	end

	text = _cpp_utf8_to_utf16(str)
	_texts[str] = text
	return text
end

function trace_call(fun, ...)
	local function _handler(msg)
		return debug.traceback(msg, 2)
	end

	local ok, msg = xpcall(fun, _handler, ...)
	if not ok then
		_cpp_log(4, _cpp_utf8_to_utf16(msg))
		return
	end
	return msg
end
