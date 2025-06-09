
require('lua')
require('unreal')
require('game')

-- call by engine
function init()
	print(_text("hello unreal!!!"))
end

-- call by engine
function game_start(game_instance)
	print(_text('game start'), towstring(game_instance))

	-- set global object
--	_engine = engine.engine(game_instance)
	_engine:set_instance(game_instance)
end

-- call by engine
function game_exit()
	_gui:on_game_exit()
	print(_text('game exist'))
end

function change_world(world_instance)
	-- _world = world.world(world_instance)
	print(_text('change world'), towstring(world))
	_world:set_instance(world_instance)

	-- test code
	_gui:on_change_world()
end
