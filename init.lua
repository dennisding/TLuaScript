
require('lua')
require('unreal')
require('game')

-- call by engine
function init()
	print(_text("hello unreal!!!"))
end

-- call by engine
function game_start(root)
	print(_text('game start'), towstring(root))

	_engine:set_root(root)
end

-- call by engine
function game_exit()
	print(_text('game exist'))

	_gui:on_game_exit()
end

-- call by engine
function change_world(world)
	print(_text('change world'), towstring(world))

	_world:set_world(world)
	_gui:on_change_world()
end
