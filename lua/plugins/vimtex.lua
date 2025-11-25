return {
	"lervag/vimtex",
	lazy = false, -- VimTeX is a filetype plugin, it loads itself when opening .tex files
	init = function()
		-- Skim on macOS, zathura on Linux/Windows
		vim.g.vimtex_view_method = (vim.uv.os_uname().sysname == "Darwin") and "skim" or "zathura"

		-- Prevent VimTeX from automatically opening the Quickfix window on warnings
		vim.g.vimtex_quickfix_mode = 0
	end,
	config = function()
		-- Rebuild on write (Save)
		-- We use VimtexCompileSS (Single Shot) to compile once when the file is saved.
		vim.api.nvim_create_autocmd("BufWritePost", {
			pattern = "*.tex",
			callback = function()
				vim.cmd("VimtexCompileSS")
			end,
		})
	end,
}
