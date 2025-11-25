return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "auto", -- This lets catppuccin switch based on 'set background'
				background = { light = "latte", dark = "mocha" },
				transparent_background = false,
				show_end_of_buffer = false,
				term_colors = false,
				default_integrations = true,
				integrations = {
					cmp = true,
					gitsigns = true,
					nvimtree = true,
					telescope = true,
					treesitter = true,
				},
			})

			vim.cmd.colorscheme("catppuccin")
		end,
	},
	{
		"f-person/auto-dark-mode.nvim",
		lazy = false, -- Must load immediately to prevent theme flashing
		priority = 1001, -- Load before catppuccin
		opts = {
			update_interval = 1000, -- Check every second
			set_dark_mode = function()
				vim.api.nvim_set_option_value("background", "dark", {})
				vim.cmd("colorscheme catppuccin")
			end,
			set_light_mode = function()
				vim.api.nvim_set_option_value("background", "light", {})
				vim.cmd("colorscheme catppuccin")
			end,
		},
	},
}
