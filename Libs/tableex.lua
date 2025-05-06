
tableex = {}

function tableex.clear(table_value)
	local keys = {}
	for key, _ in pairs(table_value) do
		table.insert(keys, key)
	end

	for key, _ in ipairs(table_value) do
		table.insert(keys, key)
	end
	for _, key in ipairs(keys) do
		table_value[key] = nil
	end
	return table_value
end

function tableex.copy(table)
	local new_table = {}
	for k, v in pairs(table) do
		new_table[k] = v
	end

	return new_table
end

function tableex.deep_copy(table)
	local new_table = {}
	for k, v in pairs(table) do
		if type(v) == 'table' then
			v = table.deep_copy(v)
		end
		new_table[k] = v
	end

	return new_table
end
