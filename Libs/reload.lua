-- 0. reload不是银弹, 不能解决所有问题, reload解决不了的, 请重启
-- 1. basic.lua 和 sys.lua 不进行reload
-- 3. 已经构建好的table, 只更新table里面的内容, 不更新table本身

local function process_import_module()
	print(_text("process_import_module"))
	local modules = tablex.copy(_sys.modules)
	for name, _ in pairs(modules) do
		safe_import(name)
	end
end

local _reload_table = nil

local function _reload_attr(name, old, new)
	-- 解决循环引用的问题
	if _sys.reloading[old] then
		return old
	end

	if type(old) ~= 'table' then
		return new
	end
	_sys.reloading[old] = true
	return _reload_table(name, old, new)
end

-- 主要更新: 增, 删, 改
function _reload_table(name, old, new)
	if old == new then
		return old
	end
	-- update attribute
	local new_copy = tablex.copy(new)
	for key, value in pairs(new_copy) do
		local result = _reload_attr(key, old[key], value)
		old[key] = result
		new[key] = result
	end
	for index, value in pairs(new_copy) do
		local result = _reload_attr(index, old[index], value)
		old[index] = result
		new[index] = result
	end

	return old
end

-- 需要处理
-- global function
-- global table
-- global class
local function process_require_module()
	local old_env = tablex.copy(_ENV)
	local loaded = tablex.copy(_sys.loaded)
	tablex.clear(_sys.loaded)

	for name, module in pairs(loaded) do
		require(name)
	end
	_reload_table('global', old_env, _ENV)
end

local function do_reload()
	process_require_module()
	process_import_module()
end

-- 需要处理
-- 1. 处理require引入的模块
-- 2. 处理_import引入的模块
-- 3. 处理_class对象
function _reload()
	_sys.reloading = {}
	_sys.reload_table = _reload_table

	print(_text('reload lua code'))
	trace_call(do_reload)

	_sys.reloading = false
end