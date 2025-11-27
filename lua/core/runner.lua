local A = {}

A.new = function(terminal)
	local M = {}
	M.state = { term = terminal }

	M.start_runner = function()
		local root = vim.fs.root(0, ".git") or vim.fn.getcwd()
		local script_path = (root .. "/run-project.lua") or (root .. "/.run-project.lua")

		if vim.fn.filereadable(script_path) == 1 then
			local cmd = string.format("nvim -l %q", script_path)
			vim.notify("Starting project runner", vim.log.levels.INFO)
			terminal.send_command(cmd)
		else
			vim.notify("No run-project.lua found in root", vim.log.levels.WARN)
		end
	end

	return M
end

return A
