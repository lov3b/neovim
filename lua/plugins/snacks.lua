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
			doc = { inline = false },
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
		statuscolumn = {
			enabled = true,
			left = { "git", "sign", "mark" },
			right = { "fold" },
			git = { patterns = { "GitSigns", "MiniDiffSign" } },
		},
		scroll = { enabled = false }, -- Smooth scrolling
		words = { enabled = true }, -- Highlight LSP references of the symbol under the cursor; <leader>uW toggles
		scope = { enabled = true }, -- ii/ai textobjects and [i/]i jumps by indent scope
		picker = {
			enabled = true,
			layout = { preset = "telescope" },
			sources = {
				explorer = {
					layout = {
						preset = "sidebar",
						preview = false,
						layout = {
							position = "left",
							width = 30,
						},
					},
					auto_close = false,
					focus = "list",
					jump = { close = false },
					tree = true,
					hidden = true, -- show dotfiles
					git_status = true,
					diagnostics = true,
				},
			},
		},
		explorer = { enabled = true, replace_netrw = false }, -- We use Oil instead of NetRW
	},
	keys = {
		{
			"<leader>fe",
			function()
				Snacks.explorer()
			end,
			desc = "Toggle Explorer Sidebar",
		},
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
			"<leader>gs",
			function()
				Snacks.picker.git_status()
			end,
			desc = "Git Status",
		},
		{
			"<leader>gd",
			function()
				Snacks.picker.git_diff()
			end,
			desc = "Git Diff (Hunks)",
		},
		{
			"<leader>gL",
			function()
				Snacks.picker.git_log()
			end,
			desc = "Git Log",
		},
		{
			"<leader>gB",
			function()
				Snacks.gitbrowse()
			end,
			desc = "Git Browse",
		},
		{
			"<leader>gb",
			function()
				Snacks.git.blame_line()
			end,
			desc = "Git Blame Line",
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
		{
			"<leader>t",
			function()
				Snacks.terminal()
			end,
			desc = "Toggle Terminal",
		},

		-- Picker
		{
			"<leader>ff",
			function()
				Snacks.picker.files()
			end,
			desc = "Picker: Find Files",
		},
		{
			"<C-p>",
			function()
				Snacks.picker.git_files()
			end,
			desc = "Picker: Find Git Files",
		},
		{
			"<leader>fg",
			function()
				Snacks.picker.grep()
			end,
			desc = "Picker: Live grep",
		},
		{
			"<leader>fr",
			function()
				Snacks.picker.recent()
			end,
			desc = "Picker: Recent",
		},
		{
			"gr",
			function()
				Snacks.picker.lsp_references()
			end,
			desc = "Picker: LSP References",
		},
		{
			"gi",
			function()
				Snacks.picker.lsp_incoming_calls()
			end,
			desc = "Picker: LSP Incoming Calls",
		},
		{
			"<leader>fb",
			function()
				Snacks.picker.buffers()
			end,
			desc = "Picker: Find Buffers",
		},
		{
			"<leader>fd",
			function()
				Snacks.picker.diagnostics()
			end,
			desc = "Picker: Diagnostics",
		},
		{
			"<leader>fs",
			function()
				Snacks.picker.lsp_symbols()
			end,
			desc = "Picker: LSP Symbols",
		},
		{
			"<leader>fh",
			function()
				Snacks.picker.help()
			end,
			desc = "Picker: Help",
		},
		{
			"<leader>fk",
			function()
				Snacks.picker.keymaps()
			end,
			desc = "Picker: Keymaps",
		},
		{
			"<leader>fu",
			function()
				Snacks.picker.undo()
			end,
			desc = "Picker: Undo History",
		},
		{
			"<leader>fR",
			function()
				Snacks.picker.resume()
			end,
			desc = "Picker: Resume Last",
		},
		{
			"<leader>fl",
			function()
				Snacks.picker.lsp_config()
			end,
			desc = "Picker: LSP Servers",
		},
		{
			"]r",
			function()
				Snacks.words.jump(vim.v.count1, true)
			end,
			desc = "Next Reference",
		},
		{
			"[r",
			function()
				Snacks.words.jump(-vim.v.count1, true)
			end,
			desc = "Prev Reference",
		},
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

				Snacks.toggle
					.new({
						name = "Format on Save",
						get = function()
							return not vim.g.disable_autoformat
						end,
						set = function(is_enabled)
							vim.g.disable_autoformat = not is_enabled
						end,
					})
					:map("<leader>uf")
				Snacks.toggle.inlay_hints():map("<leader>uh")
				Snacks.toggle.diagnostics():map("<leader>ud")
				Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
				Snacks.toggle.words():map("<leader>uW")
			end,
		})
	end,
}
