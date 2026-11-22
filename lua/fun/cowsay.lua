--- Minimal Lua cowsay, reading cowsay's own .cow files.
local M = {}

local text = require("fun.text")

---@class fun.Cow
---@field name string
---@field art string picture with $thoughts, $eyes and $tongue left in
---@field eyes? fun(eyes: string): string what the .cow file's Perl does to $eyes

-- The .cow files that run Perl on $eyes before the picture. Perl can't be read
-- out of the file, so each is written out here, keyed by cow name.
local eye_hacks = {
	sus = function(e) -- $eyes = '  ' unless ($eyes ne 'oo');
		return e == "oo" and "  " or e
	end,
	["three-eyes"] = function(e) -- $extra = chop($eyes); $eyes .= ($extra x 2);
		return e:sub(1, -2) .. e:sub(-1):rep(2)
	end,
	udder = function(e) -- $other_eye = chop($eyes); $eyes .= " $other_eye";
		return e:sub(1, -2) .. " " .. e:sub(-1)
	end,
}

--- Parses the source of a .cow file: the Perl heredoc `$the_cow = <<EOC; ... EOC`.
---@param name string
---@param src string
---@return fun.Cow? cow
---@return string? err when there is no heredoc
function M.parse(name, src)
	local quote, art = src:match("<<%s*([\"']?)EOC%1;?[^\n]*\n(.-)\nEOC")
	if not art then
		return nil, "no `<<EOC` heredoc"
	end
	art = art:gsub("%${(%w+)}", "$%1")
	if quote ~= "'" then -- an interpolating heredoc: \\ is \, \@ is @, \$ is $
		art = art:gsub("\\(.)", "%1")
	end
	local lines = vim.tbl_map(function(l)
		return (text.expand_tabs(l, 8):gsub("%s+$", ""))
	end, vim.split(art, "\n", { plain = true }))
	while lines[#lines] == "" do
		lines[#lines] = nil
	end
	return { name = name, art = table.concat(lines, "\n"), eyes = eye_hacks[name] }
end

--- Reads and parses a .cow file.
---@param path string
---@return fun.Cow? cow
---@return string? err
function M.load(path)
	local name = vim.fn.fnamemodify(path, ":t:r")
	local file, open_err = io.open(path, "r")
	if not file then
		return nil, ("reading cow %s: %s"):format(path, open_err)
	end
	local src = file:read("*a")
	file:close()
	local cow, parse_err = M.parse(name, src)
	if not cow then
		return nil, ("parsing cow %s: %s"):format(path, parse_err)
	end
	return cow
end

--- Finds cows/*.cow on the runtimepath. Earlier runtimepath entries win.
---@return table<string, string> path by cow name
function M.find()
	local ret = {}
	for _, path in ipairs(vim.api.nvim_get_runtime_file("cows/*.cow", true)) do
		local name = vim.fn.fnamemodify(path, ":t:r")
		ret[name] = ret[name] or path
	end
	return ret
end

---@param lines string[]
---@param think boolean
---@return string[]
local function bubble(lines, think)
	local width = text.size(lines)
	local function borders(i)
		if think then
			return "(", ")"
		end
		if #lines == 1 then
			return "<", ">"
		end
		if i == 1 then
			return "/", "\\"
		end
		if i == #lines then
			return "\\", "/"
		end
		return "|", "|"
	end
	local ret = { " " .. ("_"):rep(width + 2) }
	for i, l in ipairs(lines) do
		local left, right = borders(i)
		ret[#ret + 1] = left .. " " .. l .. (" "):rep(width - vim.api.nvim_strwidth(l)) .. " " .. right
	end
	ret[#ret + 1] = " " .. ("-"):rep(width + 2)
	return ret
end

--- `cowsay -n` (or `cowthink -n`): `lines` in a bubble, unwrapped, above the cow.
---@param lines string[]
---@param cow fun.Cow
---@param opts? { think?: boolean, eyes?: string, tongue?: string }
---@return string[]
function M.say(lines, cow, opts)
	opts = opts or {}
	local eyes = opts.eyes or "oo"
	eyes = cow.eyes and cow.eyes(eyes) or eyes
	local art = cow.art
		:gsub("%$thoughts", opts.think and "o" or "\\")
		:gsub("%$eyes", (eyes:gsub("%%", "%%%%")))
		:gsub("%$tongue", ((opts.tongue or "  "):gsub("%%", "%%%%")))
	return vim.list_extend(bubble(lines, opts.think == true), vim.split(art, "\n", { plain = true }))
end

return M
