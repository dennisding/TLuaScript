
require('lua')
require('unreal')
require('game')

function init()
	print(_text("hello unreal!!!"))
end

function game_start()
	print(_text('game start'))
end

function game_exit()
	_gui:on_game_exit()
	print(_text('game exist'))
end