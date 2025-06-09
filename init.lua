
require('lua')
require('unreal')
require('game')

-- call by engine
function init()
	print(_text("hello unreal!!!"))
end

-- call by engine
function game_start()
	print(_text('game start'))
end

-- call by engine
function game_exit()
	_gui:on_game_exit()
	print(_text('game exist'))
end