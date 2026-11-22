--- A set of enabled ids saved as a JSON list, with a Snacks picker to toggle them.
local M = {}

---@class fun.Toggle.Group
---@field id string shown in the picker, e.g. "off/*"
---@field desc string
---@field ids fun(): string[] the ids the row toggles together

---@class fun.Toggle.Opts
---@field title string picker title
---@field file string where the enabled ids are saved
---@field all fun(): string[] every id, in display order
---@field default string[] enabled while `file` doesn't exist
---@field groups? fun.Toggle.Group[] rows that toggle many ids at once
---@field hl? fun(id: string): string? highlight group for an id

---@class fun.Toggle
---@field opts fun.Toggle.Opts
---@field is_enabled_by_id table<string, boolean>
local Toggle = {}
Toggle.__index = Toggle

---@param path string
---@return string[]? ids nil when the file doesn't exist
---@return string? err when it exists but can't be read
local function read_ids(path)
	local file = io.open(path, "r")
	if not file then
		return nil -- not saved yet: the defaults apply
	end
	local src = file:read("*a")
	file:close()
	local ok, ids = pcall(vim.json.decode, src)
	if not ok or type(ids) ~= "table" or not vim.islist(ids) then
		return nil, ("reading %s: expected a JSON list of ids"):format(path)
	end
	return ids
end

--- Loads the saved set from `opts.file`, or `opts.default` when there is none.
---@param opts fun.Toggle.Opts
---@return fun.Toggle toggle always usable, with the defaults if the file is broken
---@return string? err when the file exists but can't be read
function M.load(opts)
	local ids, err = read_ids(opts.file)
	local self = setmetatable({ opts = opts, is_enabled_by_id = {} }, Toggle)
	for _, id in ipairs(ids or opts.default) do
		self.is_enabled_by_id[id] = true
	end
	return self, err
end

---@param id string
---@return boolean
function Toggle:is_enabled(id)
	return self.is_enabled_by_id[id] == true
end

--- The enabled ids that exist, in display order.
---@return string[]
function Toggle:enabled()
	return vim.tbl_filter(function(id)
		return self:is_enabled(id)
	end, self.opts.all())
end

--- Turns `ids` on or off and saves.
---@param ids string[]
---@param on boolean
---@return string? err when saving fails; the change still applies in memory
function Toggle:set(ids, on)
	for _, id in ipairs(ids) do
		self.is_enabled_by_id[id] = on or nil
	end
	vim.fn.mkdir(vim.fs.dirname(self.opts.file), "p")
	local file, err = io.open(self.opts.file, "w")
	if not file then
		return ("saving %s: %s"):format(self.opts.file, err)
	end
	file:write(vim.json.encode(self:enabled()))
	file:close()
end

---@return table[] picker items: the groups, then one row per id
function Toggle:items()
	local function is_on(id)
		return self:is_enabled(id)
	end
	local items = {}
	for _, group in ipairs(self.opts.groups or {}) do
		local ids = group.ids()
		local on = #vim.tbl_filter(is_on, ids) == #ids
		items[#items + 1] =
			{ text = group.id .. " " .. group.desc, id = group.id, desc = group.desc, ids = ids, on = on }
	end
	for _, id in ipairs(self.opts.all()) do
		items[#items + 1] = { text = id, id = id, ids = { id }, on = is_on(id) }
	end
	return items
end

--- Opens a picker where <CR> toggles the row under the cursor.
---@param on_close fun(err?: string) called when the picker closes, with the last save error
---@return snacks.Picker
function Toggle:choose(on_close)
	local save_err
	return Snacks.picker({
		title = self.opts.title,
		layout = { preset = "select" },
		finder = function()
			return self:items()
		end,
		format = function(item)
			return {
				{ item.on and "[x] " or "[ ] ", item.on and "DiagnosticOk" or "Comment" },
				{ item.id, self.opts.hl and self.opts.hl(item.id) or "Normal" },
				{ item.desc and ("  " .. item.desc) or "", "Comment" },
			}
		end,
		confirm = function(picker, item)
			if not item then
				return
			end
			save_err = self:set(item.ids, not item.on)
			picker:refresh()
		end,
		on_close = function()
			vim.schedule(function()
				on_close(save_err)
			end)
		end,
	})
end

return M
