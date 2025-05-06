

stringex = {}

function stringex.strip(s)
	return string.match(s, "^%s*(.-)%s*$")
end