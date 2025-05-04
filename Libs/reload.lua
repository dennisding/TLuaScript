-- 0. reload不是银弹, 不能解决所有问题, reload解决不了的, 请重启
-- 1. basic.lua 和 sys.lua 不进行reload
-- 3. 已经构建好的table, 只更新table里面的内容, 不更新table本身

require(_text('tableex'))

-- 需要处理
-- global function
-- global table
-- global class
local function process_require_module()
	local loaded = tableex.copy(_sys.loaded)
	tableex.clear(_sys.loaded)
	for name, module in pairs(loaded) do
		require(name)
	end
end

local function process_import_module()
	print(_text("process_import_module"))
end

function _reload_update_table(old_table, new_table)
	return
end

local _reload_table = nil

local function _reload_attr(name, old, new)
	if old == nil then
		return new
	end

	if type(old) ~= 'table' then
		return new
	end

	return _reload_table(name, old, new)
end

-- 主要更新: 增, 删, 改
function _reload_table(name, old, new)
	-- update attribute
	local new_copy = tableex.copy(new)
	for k, v in pairs(new_copy) do
		old[k] = _reload_attr(k, old[k], v)
	end

	return old
end

-- 需要处理
-- 1. 处理require引入的模块
-- 2. 处理_import引入的模块
-- 3. 处理_class对象
function reload()
	_sys.reloading = true
	_sys.reload_table = _reload_table

	print(_text('reload lua code222'))
	process_require_module()
	process_import_module()

	_sys.reloading = false
end