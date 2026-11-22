--- Display-width helpers for blocks of text lines.
local M = {}

--- Replaces tabs with spaces up to the next tab stop.
---@param line string
---@param tabstop integer
---@return string
function M.expand_tabs(line, tabstop)
	local parts = vim.split(line, "\t", { plain = true })
	local ret = parts[1]
	for i = 2, #parts do
		ret = ret .. (" "):rep(tabstop - vim.api.nvim_strwidth(ret) % tabstop) .. parts[i]
	end
	return ret
end

--- The display width of the widest line and the number of lines.
---@param lines string[]
---@return integer width
---@return integer height
function M.size(lines)
	local width = 0
	for _, l in ipairs(lines) do
		width = math.max(width, vim.api.nvim_strwidth(l))
	end
	return width, #lines
end

--- Pads every line with spaces to the width of the widest one.
---@param lines string[]
---@return string[]
function M.pad_right(lines)
	local width = M.size(lines)
	return vim.tbl_map(function(l)
		return l .. (" "):rep(width - vim.api.nvim_strwidth(l))
	end, lines)
end

return M
