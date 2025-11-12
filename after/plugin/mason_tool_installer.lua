require("mason").setup() -- safe even if already called
require("mason-tool-installer").setup({
	ensure_installed = {
		-- Lua
		"stylua",
		-- Python
		"black",
		"isort",
		-- Web stuff
		"prettier",
		-- Rust
		"rustfmt",
		-- C/C++
		"clang-format",
		-- Shell
		"shfmt",
		-- Kotlin
		"ktlint",
		-- Java
		"google-java-format",
	},
	run_on_start = true,
})
