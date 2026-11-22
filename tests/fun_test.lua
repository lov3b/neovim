-- Tests for lua/fun (the dashboard's fortune | cowsay | lolcat).
-- Run from anywhere: nvim --clean --headless -l tests/fun_test.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.rtp:prepend(root)

local cowsay = require("fun.cowsay")
local dashboard = require("fun.dashboard")
local fortune = require("fun.fortune")
local lolcat = require("fun.lolcat")
local rand = require("fun.rand")
local text = require("fun.text")
local toggle = require("fun.toggle")

local failures = {}

local function test(name, fn)
	local ok, err = pcall(fn)
	if not ok then
		failures[#failures + 1] = name .. ": " .. tostring(err)
	end
end

local function eq(want, got)
	if not vim.deep_equal(want, got) then
		error(("\nwant: %s\ngot:  %s"):format(vim.inspect(want), vim.inspect(got)), 2)
	end
end

---@param files table<string, string> contents by relative path
---@return string dir
local function tmp_dir(files)
	local dir = vim.fn.tempname()
	for path, contents in pairs(files) do
		local full = vim.fs.joinpath(dir, path)
		vim.fn.mkdir(vim.fs.dirname(full), "p")
		local file = assert(io.open(full, "w"))
		file:write(contents)
		file:close()
	end
	vim.fn.mkdir(dir, "p")
	return dir
end

-- rand

test("rand: the same seed gives the same sequence", function()
	local a, b = rand.new(42), rand.new(42)
	for _ = 1, 100 do
		eq(a(1000), b(1000))
	end
end)

test("rand: stays in range, both bounds reached", function()
	local r, seen = rand.new(0), {}
	for _ = 1, 1000 do
		local x = r(3, 5)
		assert(x >= 3 and x <= 5, x)
		seen[x] = true
	end
	eq({ [3] = true, [4] = true, [5] = true }, seen)
end)

-- text

test("text: expand_tabs goes to the next tab stop", function()
	eq("ab  c   d", text.expand_tabs("ab\tc\td", 4))
end)

test("text: pad_right makes a rectangle by display width", function()
	eq({ "é ", "ab" }, text.pad_right({ "é", "ab" }))
end)

-- lolcat

test("lolcat: colors characters, not bytes, and merges spaces", function()
	local chunks = lolcat.chunks({ "é  x", "", "y" }, 0)
	eq(
		{ "é", "  ", "x", "\n", "\n", "y" },
		vim.tbl_map(function(c)
			return c[1]
		end, chunks)
	)
	eq("#80ed12", chunks[1].color) -- sin at 0, 2pi/3 and 4pi/3, as lolcat++
	eq(nil, chunks[2].color)
end)

-- cowsay

local default_cow = assert(cowsay.load(vim.fs.joinpath(root, "cows", "default.cow")))

test("cowsay: says like `cowsay -n moo`", function()
	eq(
		vim.split(
			[[
 _____
< moo >
 -----
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||]],
			"\n"
		),
		cowsay.say({ "moo" }, default_cow)
	)
end)

test("cowsay: thinks in a round bubble", function()
	local said = cowsay.say({ "a", "bb" }, default_cow, { think = true })
	eq({ " ____", "( a  )", "( bb )", " ----", "        o   ^__^" }, vim.list_slice(said, 1, 5))
end)

test("cowsay: parse resolves Perl escapes and ${var}", function()
	local cow = assert(cowsay.parse("x", '$the_cow = <<"EOC";\n\\\\ \\@ \\$ U${eyes}U\n\nEOC\n'))
	eq("\\ @ $ U$eyesU", cow.art)
end)

test("cowsay: parse keeps backslashes in a quoted heredoc", function()
	eq("a\\\\b", assert(cowsay.parse("x", "$the_cow = <<'EOC';\na\\\\b\nEOC\n")).art)
end)

test("cowsay: parse fails without a heredoc", function()
	local cow, err = cowsay.parse("x", "print 'moo';")
	eq(nil, cow)
	assert(err)
end)

test("cowsay: load names the file it can't read", function()
	local cow, err = cowsay.load("/nonexistent/x.cow")
	eq(nil, cow)
	assert(err:find("/nonexistent/x.cow", 1, true), err)
end)

test("cowsay: cows that compute their eyes", function()
	local function said(name)
		local cow = assert(cowsay.load(vim.fs.joinpath(root, "cows", name .. ".cow")))
		return table.concat(cowsay.say({ "x" }, cow), "\n")
	end
	assert(said("udder"):find("\n        o o\\\n", 1, true))
	assert(said("three-eyes"):find("(ooo)", 1, true))
	assert(said("sus"):find("(     )", 1, true)) -- "( $eyes  )" with no eyes
end)

test("cowsay: every vendored cow loads and fills all placeholders", function()
	local paths = cowsay.find()
	eq(51, vim.tbl_count(paths))
	for name, path in pairs(paths) do
		local cow = assert(cowsay.load(path))
		local said = table.concat(cowsay.say({ "x" }, cow, { think = true }), "\n")
		assert(not said:find("$thoughts", 1, true) and not said:find("$eyes", 1, true), name)
		assert(not said:find("$tongue", 1, true), name)
	end
end)

-- fortune

test("fortune: parse splits on % lines", function()
	eq({ "a", "b\n  c" }, fortune.parse("%\r\na\r\n%\n\n%\nb\n  c\n%\n"))
end)

test("fortune: find sees every vendored category", function()
	local db = fortune.open(fortune.find())
	local ids = db:ids()
	eq(70, #ids)
	eq(44, #vim.tbl_filter(function(id)
		return not fortune.is_offensive(id)
	end, ids))
	eq("off/", ids[#ids]:sub(1, 4)) -- the offensive ones last
end)

test("fortune: pick respects the box", function()
	local db = fortune.open(fortune.find())
	local r = rand.new(1)
	for _ = 1, 200 do
		local lines = assert(db:pick({ "fortunes", "off/vulgarity" }, r, { max_width = 30, max_lines = 3 }))
		local width, height = text.size(lines)
		assert(width <= 30 and height <= 3, vim.inspect(lines))
	end
end)

test("fortune: categories are weighed by size", function()
	local big = {}
	for i = 1, 200 do
		big[#big + 1] = "big " .. i
	end
	local dir = tmp_dir({ tiny = "tiny\n", big = table.concat(big, "\n%\n") })
	local db = fortune.open({ tiny = dir .. "/tiny", big = dir .. "/big" })
	local r, tiny = rand.new(7), 0
	for _ = 1, 2000 do
		local lines = assert(db:pick({ "tiny", "big" }, r))
		tiny = tiny + (lines[1] == "tiny" and 1 or 0)
	end
	-- by size, tiny is ~0.3%; picking categories uniformly gave ~50%
	assert(tiny < 40, tiny)
end)

test("fortune: pick names the file it can't read", function()
	local db = fortune.open({ gone = "/nonexistent/gone" })
	local lines, err = db:pick({ "gone" }, rand.new(1))
	eq(nil, lines)
	assert(err:find("/nonexistent/gone", 1, true), err)
end)

-- toggle

local function toggle_opts(file)
	return {
		title = "t",
		file = file,
		all = function()
			return { "a", "b", "c" }
		end,
		default = { "c", "a" },
	}
end

test("toggle: defaults until saved, in display order", function()
	local t, err = toggle.load(toggle_opts(tmp_dir({}) .. "/enabled.json"))
	eq(nil, err)
	eq({ "a", "c" }, t:enabled())
end)

test("toggle: a saved set round-trips", function()
	local file = tmp_dir({}) .. "/sub/enabled.json"
	local t = toggle.load(toggle_opts(file))
	eq(nil, t:set({ "a" }, false))
	eq(nil, t:set({ "b" }, true))
	local loaded, err = toggle.load(toggle_opts(file))
	eq(nil, err)
	eq({ "b", "c" }, loaded:enabled())
end)

test("toggle: a broken file gives the defaults and an error", function()
	local t, err = toggle.load(toggle_opts(tmp_dir({ ["enabled.json"] = "{nope" }) .. "/enabled.json"))
	eq({ "a", "c" }, t:enabled())
	assert(err)
end)

-- dashboard

test("dashboard: the header fits the box, or there is none", function()
	local d = dashboard.new({ seed = 3, state_dir = tmp_dir({}) })
	for _, box in ipairs({ { 120, 60 }, { 90, 25 }, { 60, 18 } }) do
		for _ = 1, 20 do
			d.fortune = nil
			local header = d:build(box[1], box[2])
			assert(not header or (header.width <= box[1] and header.height <= box[2]), vim.inspect(box))
		end
	end
	eq(nil, d:build(20, 5))
end)

test("dashboard: the same seed builds the same header", function()
	local state_dir = tmp_dir({})
	local a = dashboard.new({ seed = 9, state_dir = state_dir }):build(120, 60)
	local b = dashboard.new({ seed = 9, state_dir = state_dir }):build(120, 60)
	eq(a, b)
end)

if #failures > 0 then
	io.stderr:write(table.concat(failures, "\n\n") .. "\n")
	os.exit(1)
end
io.write("ok\n")
