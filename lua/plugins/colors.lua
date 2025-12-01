local env_override_theme = vim.env.NVIM_THEME

return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		lazy = false, -- Make sure we load this during startup
		config = function()
			require("catppuccin").setup({
				flavour = "auto", -- Automatically switch based on background
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

			if env_override_theme == "light" then
				vim.o.background = "light"
			elseif env_override_theme == "dark" then
				vim.o.background = "dark"
			end

			vim.cmd.colorscheme("catppuccin")
		end,
	},

	{
		"f-person/auto-dark-mode.nvim",
		enabled = env_override_theme == nil, -- Only enable this plugin if we aren't manually overriding via env
		priority = 1001,
		lazy = false,
		opts = {
			update_interval = 1000,
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
