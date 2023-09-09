-- lox/helpers.lua
--
-- get's the table length of a table
function tablelength(the_table)
  local count = 0
  for _ in pairs(the_table) do count = count + 1 end
  return count
end

-- takes a string and splits it based on a delimter, defaulting to empty space
function split(inputstr, sep)
	local sep = sep
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	-- (%w+)%s*=%s*(%w+)
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

-- Trims white space from the beginning and end of a string.
function trim(str)
	local st = ""
	st = string.gsub(str, "^%s+", "")
	st = string.gsub(st, "%s+$", "")
	return st
end

function StringBuilder()
	local t = {
		buffer = "",
		append = function(str) self.buffer = self.buffer .. str end,
		toString = function() return self.buffer end
	}
	return t
end