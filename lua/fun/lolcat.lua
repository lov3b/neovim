--- Minimal Lua port of the rainbow from lolcat++ (~/Documents/Code/lolcat++/src/rainbow.cpp).
---
--- Pure: returns text chunks with a "#rrggbb" color each, and leaves turning
--- colors into highlight groups to the caller.
local M = {}

---@class fun.lolcat.Chunk
---@field [1] string text; "\n" chunks separate lines
---@field color? string "#rrggbb", nil for whitespace

---@param freq number
---@param pos number
---@return string
local function color_at(freq, pos)
	local function channel(phase)
		return math.floor(math.sin(freq * pos + phase) * 127 + 128)
	end
	return ("#%02x%02x%02x"):format(channel(0), channel(2 * math.pi / 3), channel(4 * math.pi / 3))
end

---@param line string
---@return string[] UTF-8 characters
local function chars(line)
	local ret = {}
	for ch in line:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
		ret[#ret + 1] = ch
	end
	return ret
end

--- Colors `lines` like lolcat. Runs of spaces become one uncolored chunk.
---@param lines string[]
---@param offset integer where on the rainbow to start, lolcat's random seed
---@param opts? { spread?: number, freq?: number } lolcat's -p and -F
---@return fun.lolcat.Chunk[]
function M.chunks(lines, offset, opts)
	opts = opts or {}
	local spread, freq = opts.spread or 3.0, opts.freq or 0.1
	local ret = {}
	for l, line in ipairs(lines) do
		if l > 1 then
			ret[#ret + 1] = { "\n" }
		end
		for i, ch in ipairs(chars(line)) do
			local prev = ret[#ret]
			if ch ~= " " then
				ret[#ret + 1] = { ch, color = color_at(freq, (offset + (l - 1) + (i - 1)) / spread) }
			elseif prev and not prev.color and prev[1] ~= "\n" then
				prev[1] = prev[1] .. ch
			else
				ret[#ret + 1] = { ch }
			end
		end
	end
	return ret
end

return M
