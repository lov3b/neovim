local function show_preview_prompt()
	require("core.popup").ask_to_execute({
		title = "Start Typst Preview?",
		command = "TypstPreview",
		message = "Typst: Preview started.",
	})
end

return {
	"chomosuke/typst-preview.nvim",
	ft = "typst",
	version = "1.*",
	dependencies = {
		"MunifTanjim/nui.nvim",
	},
	build = function()
		require("typst-preview").update()
	end,
	config = function()
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "typst",
			group = vim.api.nvim_create_augroup("TypstAskAutoStart", { clear = true }),
			callback = show_preview_prompt,
		})
	end,
	keys = {
		{ "<leader>tp", "<cmd>TypstPreviewToggle<CR>", desc = "Toggle Typst Preview" },
	},
}