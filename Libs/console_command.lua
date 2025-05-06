
require('stringex')

-- console commands
_console_commands = _ENV._console_command or {}			-- {name:command}

setmetatable(_console_commands, {__index = _ENV})

function add_console_command(cmds)
	for name, value in pairs(cmds) do
		_console_commands[name] = value
	end
end

local function generate_command(cmd_string)
	cmd_string = string.gsub(cmd_string, '%$(%w+)', _console_commands)
	return_cmd = string.format('return %s', cmd_string)
	-- execute cmd
	local chunk, msg = load(return_cmd, 'cmd from editor', 't', _console_commands)
	if not chunk then
		chunk, msg = load(cmd_string, 'cmd from editor', 't', _console_commands)
		if not chunk then
			print(_text(msg))
		end
	end
	return chunk
end

-- lua $r								-- command shortcut
-- lua reload							-- command
-- lua print($p, _text("other infos"))	-- normal command
function _lua_process_console_command(utf16_cmd)
	local cmd_string = utf16_to_utf8(utf16_cmd)
	cmd_string = string.sub(cmd_string, 5) -- skip the 'lua '
	cmd_string = stringex.strip(cmd_string) -- remove first and last white space

	local cmd = _console_commands[cmd_string]
	if type(cmd) ~= 'function' then
		cmd = generate_command(cmd_string)
	end
	
	_ = cmd()
	if _ ~= nil then
		print(_text(tostring(_)))
	end
end

-- test code
local commands = {}
function commands.reload()
	require('reload')
	_reload()
end

commands.r = 'reload()'

add_console_command(commands)
