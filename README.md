# TLuaScript
1. 怎么使用.
checkout本项目到Unreal的Content/Script/Lua 目录下

checkout TLua 到 Plugins/TLua 目录下,
打开TLua插件.

2. 把C++和蓝图对象与Lua对象进行绑定.
	在C++代码或蓝图代码中添加一个LuaBinder的属性, 然后调用LuaBinder的Bind方法.
	TLua插件会根据名字和类型, 绑定Actors 或 Components 目录下对应的Lua对象.

3. gui蓝图与lua对象绑定.
	在Guis下编写从_gui.panel继承的Lua类, 在_init函数调用_gui.panel的_init函数
	传入对应的gui蓝图, 即可在直接使用_gui蓝图里面的属性和方法, 所有gui都有统一
	的入口, 通过 _gui.name 访问对应的 gui 对象.

	_gui.portrait:update()

