vim.pack.add({
	-- Icons & theming
	"https://github.com/echasnovski/mini.icons", -- icon provider (used by alpha, lualine, neo-tree)
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },

	-- Lua utility libs (dependencies for many plugins)
	"https://github.com/nvim-lua/plenary.nvim", -- dependency for: telescope, gitsigns, neo-tree, none-ls, project.nvim...
	"https://github.com/nvim-lua/popup.nvim", -- legacy popup helper; kept for compatibility

	-- Project management
	"https://github.com/ahmedkhalf/project.nvim", -- project root detection; dependency of the Telescope “projects” extension

	-- Fuzzy finding
	"https://github.com/nvim-telescope/telescope.nvim", -- fuzzy finder
	"https://github.com/nvim-telescope/telescope-fzf-native.nvim", -- native sorter for telescope (needs `make`)

	-- Treesitter
	"https://github.com/nvim-treesitter/nvim-treesitter", -- syntax tree engine
	"https://github.com/nvim-treesitter/nvim-treesitter-textobjects", -- depends on nvim-treesitter; extra textobjects

	-- LSP, tools & completion
	"https://github.com/williamboman/mason.nvim", -- tool installer; dependency of mason-lspconfig and mason-tool-installer
	"https://github.com/williamboman/mason-lspconfig.nvim", -- bridges mason ↔ nvim-lspconfig
	"https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim", -- auto-installs formatters/linters; depends on mason.nvim
	"https://github.com/neovim/nvim-lspconfig", -- LSP client configs; used by mason_lsp setup
	"https://github.com/hrsh7th/nvim-cmp", -- completion engine; dependency for cmp-nvim-lsp and lazydev’s cmp source
	"https://github.com/hrsh7th/cmp-nvim-lsp", -- LSP completion source; depends on nvim-cmp
	"https://github.com/L3MON4D3/LuaSnip", -- snippet engine; used as nvim-cmp snippet backend

	-- Editing QoL
	"https://github.com/windwp/nvim-autopairs", -- auto insert pairs
	"https://github.com/numToStr/Comment.nvim", -- toggle comments

	-- Git
	"https://github.com/lewis6991/gitsigns.nvim", -- git signs; depends on plenary.nvim
	"https://github.com/tpope/vim-fugitive", -- full git porcelain

	-- UI & ergonomics
	"https://github.com/folke/which-key.nvim", -- keymap hints
	"https://github.com/nvim-lualine/lualine.nvim", -- statusline; optional icons via mini.icons
	"https://github.com/goolord/alpha-nvim", -- start screen; uses mini icons provider
	"https://github.com/stevearc/oil.nvim", -- file manager in-buffer
	-- "https://github.com/ThePrimeagen/harpoon", -- marks/quick-jump

	-- Formatting/diagnostics via external tools
	"https://github.com/nvimtools/none-ls.nvim", -- null-ls fork; depends on plenary.nvim

	-- File explorer
	"https://github.com/MunifTanjim/nui.nvim", -- UI components; dependency of neo-tree
	"https://github.com/nvim-neo-tree/neo-tree.nvim", -- file explorer; depends on nui.nvim + plenary.nvim + icons

	-- Lua nvim experience
	"https://github.com/folke/lazydev.nvim", -- improves LuaLS workspace/types; provides cmp source (depends on nvim-cmp if present)
}, { load = true })

vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name, kind, path = ev.data.spec.name, ev.data.kind, ev.data.path
		if (name == "telescope-fzf-native.nvim") and (kind == "install" or kind == "update") then
			vim.system({ "make" }, { cwd = path })
		end
		if (name == "nvim-treesitter") and (kind == "install" or kind == "update") then
			vim.schedule(function()
				pcall(vim.cmd, "TSUpdate")
			end)
		end
	end,
})
