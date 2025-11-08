local hour = tonumber(os.date("%H"))
vim.opt.background = (hour >= 19 or hour < 7) and "dark" or "light"
require("catppuccin").setup({
	flavour = "auto",
	background = { light = "latte", dark = "mocha" },
	transparent_background = false,
	show_end_of_buffer = false,
	term_colors = false,
	default_integrations = true,
	integrations = { cmp = true, gitsigns = true, nvimtree = true, telescope = true, treesitter = true },
})
vim.cmd.colorscheme("catppuccin")
