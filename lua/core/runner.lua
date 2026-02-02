local A = {}

A.new = function()
	local M = {}

	M.start_runner = function()
		local root = vim.fs.root(0, ".git") or vim.fn.getcwd()

		local script_path = nil
		for _, file_name in ipairs({ "run-project.lua", ".run-project.lua" }) do
			local path = root .. "/" .. file_name

			if vim.fn.filereadable(path) == 1 then
				script_path = path
				break
			end
		end
		if not script_path then
			local choice = vim.fn.confirm("run-project.lua not found. Create it?", "&Yes\n&No", 1)
			if choice == 1 then
				local template = [[
-- Project Runner Script
-- This script is executed via 'nvim -l' in a terminal.

local is_windows = vim.fn.has("win32") == 1
local sep = is_windows and "\\" or "/"

-- Helper to run commands
local function run(cmd)
  print("Running: " .. cmd)
  -- Note: '&&' works in most modern shells including CMD and PowerShell
  os.execute(cmd)
end

-- --- EXAMPLES (Uncomment to use) ---

-- Rust
-- run("cargo run")

-- Python
-- run("python3 main.py")

-- Node.js
-- run("npm start")

-- Go
-- run("go run .")

-- C / C++
-- local exe = is_windows and "app.exe" or "./app"
-- run("gcc main.c -o app && " .. exe)

-- CMake
-- local build_dir = "build"
-- local exe = is_windows and (build_dir .. "\\Debug\\app.exe") or (build_dir .. "/app")
-- run(string.format("cmake -B %s && cmake --build %s && %s", build_dir, build_dir, exe))

-- Java
-- run("javac Main.java && java Main")

-- Gradle
-- local gradle = is_windows and "gradlew.bat" or "./gradlew"
-- run(gradle .. " run")

-- Maven
-- run("mvn exec:java -Dexec.mainClass=\"com.example.Main\"")

print("Edit run-project.lua to configure your run command!")
]]
				local new_file_path = root .. "/run-project.lua"
				local file = io.open(new_file_path, "w")
				if file then
					file:write(template)
					file:close()
					vim.cmd("edit " .. vim.fn.fnameescape(new_file_path))
					vim.notify("Created run-project.lua", vim.log.levels.INFO)
				else
					vim.notify("Failed to create run-project.lua", vim.log.levels.ERROR)
				end
			end
			return
		end

		local cmd = string.format("nvim -l %q", script_path)
		vim.notify("Starting project runner: " .. vim.fn.fnamemodify(script_path, ":t"), vim.log.levels.INFO)
		Snacks.terminal(cmd)
	end

	return M
end

return A
