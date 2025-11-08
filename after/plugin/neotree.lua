local map = vim.keymap.set

require("neo-tree").setup({
	close_if_last_window = true,
	popup_border_style = "rounded",
	sources = { "filesystem", "buffers", "git_status" },
	enable_git_status = true,
	enable_diagnostics = true,

	default_component_configs = {
		indent = { padding = 1 },
		icon = { folder_closed = "", folder_open = "", folder_empty = "" },
		git_status = {
			symbols = {
        -- stylua: ignore
        added     = "A",
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
		hijack_netrw_behavior = "disabled", -- keep netrw and Oil workflow intact
		filtered_items = {
			hide_dotfiles = false,
			hide_gitignored = true,
		},
	},
})

-- Keymaps (kept under <leader>f* to live with your Telescope file maps)
map("n", "<leader>fe", "<cmd>Neotree toggle<CR>", { desc = "Neo-tree: Toggle" })
map("n", "<leader>fr", "<cmd>Neotree reveal<CR>", { desc = "Neo-tree: Reveal current file" })
map("n", "<leader>fgs", "<cmd>Neotree git_status toggle<CR>", { desc = "Neo-tree: Git status" })
map("n", "<leader>fbf", "<cmd>Neotree buffers toggle<CR>", { desc = "Neo-tree: Buffers" })
