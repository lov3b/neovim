local M = {}

local state = {
	buf = -1,
	win = -1,
}

function M.create_terminal()
	-- Create a new buffer
	state.buf = vim.api.nvim_create_buf(false, true)

	-- We need a window to run termopen
	vim.cmd("botright 15split")
	state.win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(state.win, state.buf)

	-- Open terminal
	-- Use 'shell' option or default to bash/zsh/sh
	local shell = vim.o.shell
	if not shell or shell == "" then
		shell = "bash"
	end
	
vim.fn.termopen(shell)
    
    -- Set buffer options
    vim.bo[state.buf].bufhidden = "hide"
    vim.bo[state.buf].buflisted = false
    vim.bo[state.buf].filetype = "terminal"
end

function M.toggle_terminal()
	if vim.api.nvim_win_is_valid(state.win) then
		vim.api.nvim_win_hide(state.win)
		-- Don't reset state.win to -1 here if we want to track it? 
        -- Actually, if we hide it, the window id is invalid.
        state.win = -1
	else
		if not vim.api.nvim_buf_is_valid(state.buf) then
			M.create_terminal()
		else
			vim.cmd("botright 15split")
			state.win = vim.api.nvim_get_current_win()
			vim.api.nvim_win_set_buf(state.win, state.buf)
		end
		vim.cmd("startinsert")
	end
end

function M.send_command(cmd)
	if not vim.api.nvim_buf_is_valid(state.buf) then
		M.create_terminal()
	end

	-- Ensure window is open so user sees output
	if not vim.api.nvim_win_is_valid(state.win) then
		vim.cmd("botright 15split")
		state.win = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_buf(state.win, state.buf)
	end

	local chan = vim.bo[state.buf].channel
	if chan and chan > 0 then
		vim.api.nvim_chan_send(chan, cmd .. "\r\n")
        -- Scroll to bottom
        vim.api.nvim_win_set_cursor(state.win, {vim.api.nvim_buf_line_count(state.buf), 0})
	end
end

return M
