local M = {}

local executable_map = {
	ts_ls = { "typescript-language-server" },
	rust_analyzer = { "rust-analyzer" },
	kotlin_language_server = { "kotlin-language-server" },
	basedpyright = { "basedpyright-langserver" },
	bashls = { "bash-language-server" },
	lua_ls = { "lua-language-server" },
	debugpy = { "debugpy-adapter", "debugpy" },
	["tree-sitter-cli"] = { "tree-sitter" },
}

local python_module_map = {
	debugpy = "debugpy",
}

--- The Python interpreter on PATH, or nil. macOS and Debian ship only
--- `python3`; an active virtualenv provides both names.
function M.python()
	for _, name in ipairs({ "python3", "python" }) do
		if vim.fn.executable(name) == 1 then
			return name
		end
	end
	return nil
end

local function has_python_module(mod)
	local python = M.python()
	if not python then
		return false
	end
	vim.fn.system({ python, "-c", "import " .. mod })
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

--- Whether `executable` is provided by something other than Mason: a PATH
--- entry outside `mason_root`.
local function is_on_system_path(executable, mason_root)
	local separator = vim.fn.has("win32") == 1 and ";" or ":"
	for _, dir in ipairs(vim.split(vim.env.PATH or "", separator, { plain = true, trimempty = true })) do
		local is_mason_dir = vim.startswith(vim.fs.normalize(dir), mason_root)
		if not is_mason_dir and vim.fn.executable(vim.fs.joinpath(dir, executable)) == 1 then
			return true
		end
	end
	return false
end

--- Whether the system provides every executable the Mason package links
--- into its bin directory. Packages without executables are never shadowed.
local function is_shadowed(pkg, mason_root)
	local receipt = pkg:get_receipt():or_else(nil)
	local executables = vim.tbl_keys(receipt and receipt.links and receipt.links.bin or {})
	if #executables == 0 then
		return false
	end
	return vim.iter(executables):all(function(executable)
		return is_on_system_path(executable, mason_root)
	end)
end

--- Uninstalls every Mason package the system now provides itself, so a tool
--- installed later through the system package manager replaces Mason's copy
--- instead of living beside it. Requires `mason.setup()` to have run.
--- Returns the names of the packages being uninstalled; the uninstalls
--- themselves finish asynchronously.
function M.uninstall_shadowed()
	local mason_root = vim.fs.normalize(require("mason.settings").current.install_root_dir)
	local shadowed = vim.tbl_filter(function(pkg)
		return is_shadowed(pkg, mason_root)
	end, require("mason-registry").get_installed_packages())

	return vim.tbl_map(function(pkg)
		pkg:uninstall()
		return pkg.name
	end, shadowed)
end

function M.missing(names)
	return vim.tbl_filter(function(name)
		return not M.on_path(name)
	end, names)
end

return M
