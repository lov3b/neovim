--- fortune | cowsay | lolcat as the Snacks.dashboard header.
---
--- The app layer: wires the libraries to Neovim (runtimepath, saved choices,
--- commands, highlights, notifications). `m` on the dashboard rerolls;
--- :FortuneCategories and :CowsayCows choose what to pick from.
local M = {}

local cowsay = require("fun.cowsay")
local fortune = require("fun.fortune")
local lolcat = require("fun.lolcat")
local rand = require("fun.rand")
local text = require("fun.text")
local toggle = require("fun.toggle")

-- stylua: ignore
local default_categories = {
	"off/astrology", "off/black-humor", "off/debian", "off/definitions", "off/drugs",
	"off/knghtbrd", "off/limerick", "off/linux", "off/miscellaneous", "off/politics",
	"off/privates", "off/religion", "off/riddles", "off/sex", "off/songs-poems",
	"off/vulgarity",
}

-- stylua: ignore
local default_cows = {
	"beavis.zen", "blowfish", "bud-frogs", "cheese", "cupcake", "daemon", "dragon",
	"dragon-and-cow", "eyes", "milk",
}

local function warn(msg)
	vim.notify(msg, vim.log.levels.WARN, { title = "dashboard" })
end

---@param opts fun.Toggle.Opts
---@return fun.Toggle
local function load_toggle(opts)
	local t, err = toggle.load(opts)
	if err then
		warn(err .. "; using the defaults") -- a broken save file shouldn't hide the dashboard
	end
	return t
end

-- Highlight groups for lolcat's colors, by "#rrggbb". `:colorscheme` clears
-- all groups, so they are put back on ColorScheme.
local hl_group_by_color = {} ---@type table<string, string>

---@param color string
---@return string
local function hl_group(color)
	if not hl_group_by_color[color] then
		hl_group_by_color[color] = "Lolcat" .. color:sub(2)
		vim.api.nvim_set_hl(0, hl_group_by_color[color], { fg = color })
	end
	return hl_group_by_color[color]
end

vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("fun_dashboard_lolcat", { clear = true }),
	callback = function()
		for color, group in pairs(hl_group_by_color) do
			vim.api.nvim_set_hl(0, group, { fg = color })
		end
	end,
})

---@param chunks fun.lolcat.Chunk[]
---@return snacks.dashboard.Text[]
local function to_dashboard_text(chunks)
	return vim.tbl_map(function(chunk)
		return { chunk[1], hl = chunk.color and hl_group(chunk.color) }
	end, chunks)
end

---@param cows fun.Cow[]
---@param lines string[]
---@param box { width: integer, height: integer, think: boolean }
---@return string[][] each cow saying `lines`, for the cows that fit in the box
local function fitting(cows, lines, box)
	local ret = {}
	for _, cow in ipairs(cows) do
		local said = cowsay.say(lines, cow, { think = box.think })
		local width, height = text.size(said)
		if width <= box.width and height <= box.height then
			ret[#ret + 1] = said
		end
	end
	return ret
end

---@class fun.Dashboard
---@field reserved integer lines kept free below the header for the rest of the dashboard
---@field rand fun.Rand
---@field db fun.fortune.Db
---@field cow_paths table<string, string>
---@field loaded_cows table<string, fun.Cow|false> false when loading failed
---@field categories fun.Toggle
---@field cow_choice fun.Toggle
---@field fortune? string[] kept across resizes, so they only change the cow
---@field header? { chunks: snacks.dashboard.Text[], width: integer, height: integer }
---@field base_width? integer the dashboard width from the config
local Dashboard = {}
Dashboard.__index = Dashboard

---@class fun.Dashboard.Opts
---@field reserved? integer lines to keep free below the header (default 20)
---@field state_dir? string where the chosen categories and cows are saved (default stdpath("data"))
---@field seed? integer for the random choices (default: from the OS)

--- Sets up the header and its commands. Call once, at startup.
---@param opts? fun.Dashboard.Opts
---@return fun.Dashboard
function M.new(opts)
	opts = opts or {}
	local state_dir = opts.state_dir or vim.fn.stdpath("data")
	local db = fortune.open(fortune.find())
	local cow_paths = cowsay.find()
	local function cow_names()
		local names = vim.tbl_keys(cow_paths)
		table.sort(names)
		return names
	end
	local self = setmetatable({
		reserved = opts.reserved or 20,
		rand = rand.new(opts.seed or rand.os_seed()),
		db = db,
		cow_paths = cow_paths,
		loaded_cows = {},
		categories = load_toggle({
			title = "Fortune categories",
			file = vim.fs.joinpath(state_dir, "fortunes", "enabled.json"),
			all = function()
				return db:ids()
			end,
			default = default_categories,
			groups = {
				{
					id = "off/*",
					desc = "all offensive",
					ids = function()
						return vim.tbl_filter(fortune.is_offensive, db:ids())
					end,
				},
				{
					id = "*",
					desc = "all safe",
					ids = function()
						return vim.tbl_filter(function(id)
							return not fortune.is_offensive(id)
						end, db:ids())
					end,
				},
			},
			hl = function(id)
				return fortune.is_offensive(id) and "DiagnosticWarn" or nil
			end,
		}),
		cow_choice = load_toggle({
			title = "Cows",
			file = vim.fs.joinpath(state_dir, "cowsay", "enabled.json"),
			all = cow_names,
			default = default_cows,
			groups = { { id = "*", desc = "all cows", ids = cow_names } },
		}),
	}, Dashboard)
	self:create_commands()
	return self
end

function Dashboard:create_commands()
	local function choose(t)
		t:choose(function(err)
			if err then
				warn(err)
			end
			self:reroll()
		end)
	end
	vim.api.nvim_create_user_command("FortuneCategories", function()
		choose(self.categories)
	end, { desc = "Choose the fortune categories for the dashboard" })
	vim.api.nvim_create_user_command("CowsayCows", function()
		choose(self.cow_choice)
	end, { desc = "Choose the cows for the dashboard" })
end

---@param name string
---@return fun.Cow?
function Dashboard:cow(name)
	if self.loaded_cows[name] == nil then
		local cow, err = cowsay.load(self.cow_paths[name] or name .. ".cow")
		if not cow then
			warn(err)
		end
		self.loaded_cows[name] = cow or false
	end
	return self.loaded_cows[name] or nil
end

---@return fun.Cow[] the enabled cows, or the default cow when none are
function Dashboard:enabled_cows()
	local names = self.cow_choice:enabled()
	if #names == 0 then
		names = { "default" }
	end
	local cows = {}
	for _, name in ipairs(names) do
		cows[#cows + 1] = self:cow(name)
	end
	return cows
end

---@param max_width integer
---@param max_lines integer
---@return string[]
function Dashboard:new_fortune(max_width, max_lines)
	local categories = self.categories:enabled()
	if #categories == 0 then
		return { "No fortune categories enabled.", "Pick some with :FortuneCategories" }
	end
	local opts = { max_width = math.min(50, max_width), max_lines = math.min(10, max_lines) }
	local lines, err = self.db:pick(categories, self.rand, opts)
	if not lines then
		warn(err)
		return { "No fortune for you." }
	end
	return lines
end

--- The fortune said by a random enabled cow that fits in the box: the current
--- fortune if any cow fits it, else a new one short enough for the smallest cow.
---@param width integer
---@param height integer
---@return { chunks: snacks.dashboard.Text[], width: integer, height: integer }? nil when no cow fits
function Dashboard:build(width, height)
	local box = { width = width, height = height, think = self.rand(4) == 1 }
	local cows = self:enabled_cows()
	local fits = self.fortune and fitting(cows, self.fortune, box) or {}
	if #fits == 0 then
		local smallest
		for _, said in ipairs(fitting(cows, { "" }, box)) do
			smallest = math.min(smallest or #said, #said)
		end
		if not smallest then
			return nil
		end
		self.fortune = self:new_fortune(width - 4, height - smallest + 1)
		fits = fitting(cows, self.fortune, box)
	end
	if #fits == 0 then
		return nil
	end
	-- a rectangle, so the dashboard centers the whole cow rather than each line
	local lines = text.pad_right(fits[self.rand(#fits)])
	local w, h = text.size(lines)
	return { chunks = to_dashboard_text(lolcat.chunks(lines, self.rand(0, 255))), width = w, height = h }
end

function Dashboard:reroll()
	self.fortune, self.header = nil, nil
	Snacks.dashboard.update()
end

--- A Snacks.dashboard section showing the header, as wide as the window allows.
---@param item? table extra dashboard item fields, e.g. { padding = 2 }
---@return fun(dash: snacks.dashboard.Class): snacks.dashboard.Item|{}
function Dashboard:section(item)
	return function(dash)
		-- _size is private to snacks, but sections get no other way to see the window size
		local width, height = dash._size.width - 4, dash._size.height - self.reserved
		local base_width = self.base_width or dash.opts.width
		self.base_width = base_width
		if not self.header or self.header.width > width or self.header.height > height then
			self.header = self:build(width, height)
		end
		-- widen the dashboard for wide cows, so they are centered too
		dash.opts.width = math.max(base_width, self.header and self.header.width or 0)
		-- Not a dashboard item with a key: snacks closes a floating dashboard
		-- before running an item's action, and rerolling should keep it open.
		vim.keymap.set("n", "m", function()
			self:reroll()
		end, { buffer = dash.buf, nowait = true, desc = "Dashboard: new fortune" })
		if not self.header then
			return {}
		end
		return vim.tbl_extend("force", { text = self.header.chunks, align = "center", padding = 1 }, item or {})
	end
end

return M
