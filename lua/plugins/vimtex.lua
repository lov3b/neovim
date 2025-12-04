local function show_compile_prompt()
	local Menu = require("nui.menu")

	local menu = Menu({
		position = "50%",
		size = {
			width = 40,
			height = 2,
		},
		enter = true, -- Make sure that we're focused and not the document
		focusable = true, -- Ensure the window can receive focus
		zindex = 50, -- Ensure it sits above other UI elements
		border = {
			style = "rounded",
			text = {
				top = " Start Continuous Compilation? ",
				top_align = "center",
			},
		},
		win_options = {
			winhighlight = "Normal:Normal,FloatBorder:Normal",
		},
	}, {
		lines = {
			Menu.item("Yes"),
			Menu.item("No"),
		},
		max_width = 20,
		keymap = {
			focus_next = { "j", "<Down>", "<Tab>" },
			focus_prev = { "k", "<Up>", "<S-Tab>" },
			close = { "<Esc>", "<C-c>", "q" },
			submit = { "<CR>", "<Space>" },
		},
		on_close = function() end,
		on_submit = function(item)
			if item.text == "Yes" then
				vim.cmd("VimtexCompile")
				vim.notify("VimTeX: Continuous compilation started.", vim.log.levels.INFO)
			end
		end,
	})

	-- Schedule the mount to run AFTER the current event loop.
	-- This prevents the text buffer from stealing focus back immediately.
	vim.schedule(function()
		menu:mount()
	end)
end

local function get_visual_selection()
	local mode = vim.fn.mode()
	local start_pos = vim.fn.getpos("v")
	local end_pos = vim.fn.getpos(".")

	-- Convert 1-based Vim indices to 0-based API indices
	local s_row, s_col = start_pos[2] - 1, start_pos[3] - 1
	local e_row, e_col = end_pos[2] - 1, end_pos[3] - 1

	-- Ensure start is before end
	if s_row > e_row or (s_row == e_row and s_col > e_col) then
		s_row, e_row, s_col, e_col = e_row, s_row, e_col, s_col
	end

	local lines = {}
	if mode == "V" then
		lines = vim.api.nvim_buf_get_lines(0, s_row, e_row + 1, false)
	elseif mode == "v" or mode == "\22" then -- 'v' or Ctrl-V
		lines = vim.api.nvim_buf_get_text(0, s_row, s_col, e_row, e_col + 1, {})
	end

	return table.concat(lines, "\n")
end

local function count_visual_selection()
	local text = get_visual_selection()

	if not text or text == "" then
		return
	end

	local result = vim.fn.system("texcount -brief -", text)
	local show = result:gsub("%+.*", ""):gsub("%s+$", "")
	vim.notify(show, vim.log.levels.INFO, { title = "Word Count (Selection)" })
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end

return {
	"lervag/vimtex",
	lazy = false,
	dependencies = {
		"MunifTanjim/nui.nvim", -- Use nui.nvim for a nice popup.
	},
	init = function()
		-- Skim on macOS, zathura on Linux/Windows
		vim.g.vimtex_view_method = (vim.uv.os_uname().sysname == "Darwin") and "skim" or "zathura"
		vim.g.vimtex_quickfix_mode = 0
	end,
	config = function()
		-- trigger the prompt when VimTeX initializes
		vim.api.nvim_create_autocmd("User", {
			pattern = "VimtexEventInitPost",
			group = vim.api.nvim_create_augroup("VimtexAskAutoStart", { clear = true }),
			callback = show_compile_prompt,
		})
		vim.keymap.set("n", "<leader>wc", "<cmd>VimtexCountWords<cr>", { desc = "VimTeX: Count words" })
		vim.keymap.set("x", "<leader>wc", count_visual_selection, { desc = "VimTeX: Count words in selection" })
	end,
}
