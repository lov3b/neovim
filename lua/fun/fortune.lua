--- Minimal Lua fortune, reading fortune-mod's datfiles (the `%`-separated sources).
---
--- Category ids are file names under fortunes/ on the runtimepath; the
--- offensive (`fortune -o`) ones live in fortunes/off/ and are "off/" prefixed.
local M = {}

local text = require("fun.text")

--- Splits a datfile into its fortunes.
---@param src string
---@return string[]
function M.parse(src)
	local ret = {}
	src = "\n" .. src:gsub("\r", "") .. "\n"
	for _, entry in ipairs(vim.split(src, "\n%\n", { plain = true })) do
		entry = entry:gsub("^\n+", ""):gsub("\n+$", "")
		if entry ~= "" then
			ret[#ret + 1] = entry
		end
	end
	return ret
end

---@param id string
---@return boolean
function M.is_offensive(id)
	return id:find("^off/") ~= nil
end

--- Finds fortunes/* and fortunes/off/* on the runtimepath, skipping file names
--- with a dot (COPYING.txt). Earlier runtimepath entries win.
---@return table<string, string> path by category id
function M.find()
	local ret = {}
	for _, prefix in ipairs({ "", "off/" }) do
		for _, path in ipairs(vim.api.nvim_get_runtime_file("fortunes/" .. prefix .. "*", true)) do
			local id = prefix .. vim.fn.fnamemodify(path, ":t")
			local is_datfile = not id:find(".", 1, true) and vim.fn.isdirectory(path) == 0
			if is_datfile and not ret[id] then
				ret[id] = path
			end
		end
	end
	return ret
end

---@class fun.fortune.Db
---@field paths table<string, string> path by category id
---@field entries table<string, string[]> parsed categories, filled on demand
---@field sizes table<string, integer> file sizes by category id, filled on demand
local Db = {}
Db.__index = Db

--- A fortune database over the given files. Files are read when first picked from.
---@param paths table<string, string> path by category id, as from `find()`
---@return fun.fortune.Db
function M.open(paths)
	return setmetatable({ paths = paths, entries = {}, sizes = {} }, Db)
end

--- All category ids, sorted, the safe ones first.
---@return string[]
function Db:ids()
	local ids = vim.tbl_keys(self.paths)
	table.sort(ids, function(a, b)
		if M.is_offensive(a) ~= M.is_offensive(b) then
			return M.is_offensive(b)
		end
		return a < b
	end)
	return ids
end

---@param id string
---@return string[]? entries
---@return string? err
function Db:load(id)
	if self.entries[id] then
		return self.entries[id]
	end
	local path = self.paths[id]
	if not path then
		return nil, "unknown fortune category " .. id
	end
	local file, err = io.open(path, "r")
	if not file then
		return nil, ("reading fortunes %s: %s"):format(path, err)
	end
	self.entries[id] = M.parse(file:read("*a"))
	file:close()
	return self.entries[id]
end

---@param id string
---@return integer
function Db:size(id)
	if not self.sizes[id] then
		local stat = vim.uv.fs_stat(self.paths[id] or "")
		self.sizes[id] = math.max(1, stat and stat.size or 0)
	end
	return self.sizes[id]
end

--- Picks a category, weighed by file size the way fortune(6) weighs by count:
--- otherwise one with a single fortune (off/cookie) shows up as often as off/sex.
---@param categories string[]
---@param rand fun.Rand
---@return string
function Db:pick_category(categories, rand)
	local total = 0
	for _, id in ipairs(categories) do
		total = total + self:size(id)
	end
	local r = rand(total)
	for _, id in ipairs(categories) do
		r = r - self:size(id)
		if r <= 0 then
			return id
		end
	end
	return categories[#categories]
end

---@param entry string
---@return string[] # the lines, with tabs expanded and trailing space trimmed
local function to_lines(entry)
	return vim.tbl_map(function(l)
		return (text.expand_tabs(l, 4):gsub("%s+$", ""))
	end, vim.split(entry, "\n", { plain = true }))
end

--- Picks a random fortune from `categories` that fits in the box, retrying a
--- while; if none of the tries fit, returns the first one anyway.
---@param categories string[] non-empty
---@param rand fun.Rand
---@param opts? { max_width?: integer, max_lines?: integer }
---@return string[]? lines
---@return string? err when a category can't be read
function Db:pick(categories, rand, opts)
	assert(#categories > 0, "fortune: no categories to pick from")
	opts = opts or {}
	local max_width, max_lines = opts.max_width or 60, opts.max_lines or 10
	local first
	for _ = 1, 200 do
		local entries, err = self:load(self:pick_category(categories, rand))
		if not entries then
			return nil, err
		end
		local lines = #entries > 0 and to_lines(entries[rand(#entries)]) or nil
		if lines and #lines <= max_lines and text.size(lines) <= max_width then
			return lines
		end
		first = first or lines
	end
	return first
end

return M
