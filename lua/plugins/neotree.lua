return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"echasnovski/mini.icons",
		"MunifTanjim/nui.nvim",
		"s1n7ax/nvim-window-picker",
	},
	config = function()
		local map = vim.keymap.set
		local events = require("neo-tree.events")

		require("neo-tree").setup({
			close_if_last_window = true,
			popup_border_style = "rounded",
			sources = { "filesystem", "buffers", "git_status" },
			enable_git_status = true,
			enable_diagnostics = true,

			event_handlers = {
				{
					event = events.FILE_MOVED,
					handler = function(data)
						-- Notify Snacks to update LSP references/imports
						Snacks.rename.on_rename_file(data.source, data.destination)
					end,
				},
				{
					event = events.FILE_RENAMED,
					handler = function(data)
						Snacks.rename.on_rename_file(data.source, data.destination)
					end,
				},
			},

			default_component_configs = {
				indent = { padding = 1 },
				icon = { folder_closed = "", folder_open = "", folder_empty = "" },
				git_status = {
					symbols = {
						added = "A",
						modified = "M",
						deleted = "D",
						renamed = "R",
						untracked = "U",
						ignored = "I",
						unstaged = "•",
						staged = "✓",
						conflict = "✖",
					},
				},
			},
			window = {
				position = "left",
				width = 32,
				mappings = {
					["<space>"] = "toggle_node",
					["<CR>"] = "open",
					["q"] = "close_window",
					["r"] = "refresh",
					["h"] = "close_node",
					["l"] = "open",
					["t"] = "open_tabnew",
				},
			},
			filesystem = {
				bind_to_cwd = true,
				follow_current_file = { enabled = true },
				use_libuv_file_watcher = true,
				hijack_netrw_behavior = "disabled",
				filtered_items = {
					hide_dotfiles = false,
					hide_gitignored = true,
				},
			},
		})

		map("n", "<leader>fe", "<cmd>Neotree toggle<CR>", { desc = "Neo-tree: Toggle" })
		map("n", "<leader>fr", "<cmd>Neotree reveal<CR>", { desc = "Neo-tree: Reveal current file" })
		map("n", "<leader>fB", "<cmd>Neotree buffers toggle<CR>", { desc = "Neo-tree: Buffers" })
	end,
}
