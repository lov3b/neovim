local M = {}

local executable_map = {
	ts_ls = { "typescript-language-server" },
	rust_analyzer = { "rust-analyzer" },
	kotlin_language_server = { "kotlin-language-server" },
	pyright = { "pyright-langserver" },
	bashls = { "bash-language-server" },
	lua_ls = { "lua-language-server" },
	debugpy = { "debugpy-adapter", "debugpy" },
}

function M.on_path(name)
	for _, executable in ipairs(executable_map[name] or { name }) do
		if vim.fn.executable(executable) == 1 then
			return true
		end
	end

	return false
end

function M.missing(names)
	return vim.tbl_filter(function(name)
		return not M.on_path(name)
	end, names)
end

return M
