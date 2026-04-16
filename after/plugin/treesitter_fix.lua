-- Workaround for Neovim 0.12 + nvim-treesitter: stale tree-sitter nodes
-- can have a nil :range() method during injection reparsing, causing crashes
-- in query directives that call vim.treesitter.get_node_text().
local query = require("vim.treesitter.query")
local opts = { force = true, all = false }

local function node_valid(node)
	return node and pcall(node.range, node)
end

query.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
	local node = match[pred[2]]
	if not node_valid(node) then
		return
	end
	local ok, text = pcall(vim.treesitter.get_node_text, node, bufnr)
	if ok and text then
		local injection_alias = text:lower()
		local ft_match = vim.filetype.match({ filename = "a." .. injection_alias })
		metadata["injection.language"] = ft_match or injection_alias
	end
end, opts)

query.add_directive("set-lang-from-mimetype!", function(match, _, bufnr, pred, metadata)
	local node = match[pred[2]]
	if not node_valid(node) then
		return
	end
	local ok, text = pcall(vim.treesitter.get_node_text, node, bufnr)
	if ok and text then
		local html_types = {
			["importmap"] = "json",
			["module"] = "javascript",
			["application/ecmascript"] = "javascript",
			["text/ecmascript"] = "javascript",
		}
		if html_types[text] then
			metadata["injection.language"] = html_types[text]
		else
			local parts = vim.split(text, "/", {})
			metadata["injection.language"] = parts[#parts]
		end
	end
end, opts)

query.add_directive("downcase!", function(match, _, bufnr, pred, metadata)
	local id = pred[2]
	local node = match[id]
	if not node_valid(node) then
		return
	end
	local ok, text = pcall(vim.treesitter.get_node_text, node, bufnr, { metadata = metadata[id] })
	if ok then
		if not metadata[id] then
			metadata[id] = {}
		end
		metadata[id].text = string.lower(text or "")
	end
end, opts)
