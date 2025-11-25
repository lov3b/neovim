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
	end,
}
