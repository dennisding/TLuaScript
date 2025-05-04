
require(_text('stringex'))

-- console commands
_console_commands = {}		-- {name:function}
_console_replace = {}		-- {name:replacecode}

setmetatable(_console_commands, {__index = _ENV})

function add_console_command(cmds)
	for name, value in pairs(cmds) do
		_console_commands[name] = value
	end
end

-- lua $r								-- command shortcut
-- lua reload							-- command
-- lua print($p, _text("other infos"))	-- normal command
function _lua_process_console_command(utf16_cmd)
	local cmd_string = utf16_to_utf8(utf16_cmd)
	cmd_string = string.sub(cmd_string, 5) -- skip the 'lua '
	cmd_string = stringex.strip(cmd_string) -- remove first and last white space

	local cmd = _console_commands[cmd_string]
	if type(cmd) == 'function' then
		cmd()
		return
	end

	-- cmd = _process_command(cmd)
	cmd_string = string.gsub(cmd_string, '%$(%w+)', _console_commands)
	-- execute cmd
	local fun = load(cmd_string, 'cmd from editor', 't', _console_commands)
	_ = fun()
end

-- test code
local commands = {}
function commands.reload()
	require(_text('reload'))
	reload()
end

commands.r = 'reload()'

add_console_command(commands)
