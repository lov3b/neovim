vim.pack.add({
	"https://github.com/echasnovski/mini.icons",
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/nvim-lua/popup.nvim",
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
	"https://github.com/ahmedkhalf/project.nvim",
	"https://github.com/nvim-telescope/telescope.nvim",
	"https://github.com/nvim-telescope/telescope-fzf-native.nvim",
	"https://github.com/nvim-treesitter/nvim-treesitter",
	"https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
	"https://github.com/williamboman/mason.nvim",
	"https://github.com/williamboman/mason-lspconfig.nvim",
	"https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/hrsh7th/nvim-cmp",
	"https://github.com/hrsh7th/cmp-nvim-lsp",
	"https://github.com/L3MON4D3/LuaSnip",
	"https://github.com/windwp/nvim-autopairs",
	"https://github.com/numToStr/Comment.nvim",
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/folke/which-key.nvim",
	"https://github.com/nvim-lualine/lualine.nvim",
	"https://github.com/goolord/alpha-nvim",
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/nvimtools/none-ls.nvim",

	"https://github.com/MunifTanjim/nui.nvim",
	"https://github.com/nvim-neo-tree/neo-tree.nvim",
	"https://github.com/folke/lazydev.nvim", -- For nvim types

	-- 'https://github.com/tpope/vim-fugitive',
	-- 'https://github.com/ThePrimeagen/harpoon',
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
