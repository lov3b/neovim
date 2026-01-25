local M = {}

function M.ask_to_execute(opts)
	local Menu = require("nui.menu")

	local menu = Menu({
		position = "50%",
		size = {
			width = opts.width or 40,
			height = 2,
		},
		enter = true,
		focusable = true,
		zindex = 50,
		border = {
			style = "rounded",
			text = {
				top = " " .. opts.title .. " ",
				top_align = "center",
			},
		},
		win_options = {
			winhighlight = "Normal:Normal,FloatBorder:Normal",
		},
	}, {
		lines = {
			Menu.item("Yes"),
			Menu.item("No"),
		},
		max_width = 20,
		keymap = {
			focus_next = { "j", "<Down>", "<Tab>" },
			focus_prev = { "k", "<Up>", "<S-Tab>" },
			close = { "<Esc>", "<C-c>", "q" },
			submit = { "<CR>", "<Space>" },
		},
		on_close = function() end,
		on_submit = function(item)
			if item.text == "Yes" then
				if type(opts.command) == "function" then
					opts.command()
				else
					vim.cmd(opts.command)
				end
				if opts.message then
					vim.notify(opts.message, vim.log.levels.INFO)
				end
			end
		end,
	})

	vim.schedule(function()
		menu:mount()
	end)
end

return M
