
require('lua')
require('unreal')
require('game')

function init()
	print(_text("hello unreal!!!"))
end

function exit()
	_gui:game_exist()
	print(_text('goodbye unreal'))
end