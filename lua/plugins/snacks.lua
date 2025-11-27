return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		bigfile = { enabled = true }, -- Prevents freezing on large files
		dashboard = { enabled = true }, -- Replaces alpha.nvim
		input = { enabled = true }, -- Better UI for "Rename" (vim.ui.input)
		notifier = { enabled = true }, -- Better notifications (vim.notify)
		quickfile = { enabled = true, exclude = { "latex" } }, -- Speed up opening files
		image = {
			enabled = true,
			formats = {
				"png",
				"jpg",
				"jpeg",
				"gif",
				"bmp",
				"webp",
				"tiff",
				"heic",
				"icns",
				"pdf",
			},
		},

		indent = { enabled = false }, -- "Better" indentation guides
		statuscolumn = { enabled = false }, -- Disabled: We rely Gitsigns/LSP setup
		scroll = { enabled = false }, -- Smooth scrolling
		words = { enabled = false }, -- Auto-highlight word under cursor
		picker = { enabled = false }, -- Disabled: We're using Telescope
		explorer = { enabled = false }, -- Disabled: We're using Neo-tree
	},
	keys = {
		-- Top Pickers & Explorer (use Snacks for things Telescope/Neo-tree doesn't do easily)
		{
			"<leader>.",
			function()
				Snacks.scratch()
			end,
			desc = "Toggle Scratch Buffer",
		},
		{
			"<leader>S",
			function()
				Snacks.scratch.select()
			end,
			desc = "Select Scratch Buffer",
		},

		-- Git
		{
			"<leader>gB",
			function()
				Snacks.gitbrowse()
			end,
			desc = "Git Browse",
		},
		{
			"<leader>gg",
			function()
				Snacks.lazygit()
			end,
			desc = "Lazygit",
		},
		{
			"<leader>gl",
			function()
				Snacks.lazygit.log()
			end,
			desc = "Lazygit Log (Current File)",
		},

		-- Other Utilities
		{
			"<leader>bd",
			function()
				Snacks.bufdelete()
			end,
			desc = "Delete Buffer",
		},
		{
			"<leader>rf",
			function()
				Snacks.rename.rename_file()
			end,
			desc = "Rename File",
		},
		{
			"<leader>un",
			function()
				Snacks.notifier.hide()
			end,
			desc = "Dismiss All Notifications",
		},
		-- {
		-- 	"<leader>t",
		-- 	function()
		-- 		Snacks.terminal()
		-- 	end,
		-- 	desc = "Toggle Terminal",
		-- },
	},
	init = function()
		vim.api.nvim_create_autocmd("User", {
			pattern = "VeryLazy",
			callback = function()
				-- globals for debugging
				_G.dd = function(...)
					Snacks.debug.inspect(...)
				end
				_G.bt = function()
					Snacks.debug.backtrace()
				end
				vim.print = _G.dd -- Override print to use snacks for cleaner output
			end,
		})
	end,
}
