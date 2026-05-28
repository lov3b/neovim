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

local python_module_map = {
	debugpy = "debugpy",
}

local function has_python_module(mod)
	if vim.fn.executable("python") ~= 1 then
		return false
	end
	vim.fn.system({ "python", "-c", "import " .. mod })
	return vim.v.shell_error == 0
end

function M.on_path(name)
	for _, executable in ipairs(executable_map[name] or { name }) do
		if vim.fn.executable(executable) == 1 then
			return true
		end
	end

	local mod = python_module_map[name]
	if mod and has_python_module(mod) then
		return true
	end

	return false
end

function M.missing(names)
	return vim.tbl_filter(function(name)
		return not M.on_path(name)
	end, names)
end

return M
