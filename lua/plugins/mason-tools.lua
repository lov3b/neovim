return {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
        require("mason").setup() 
        require("mason-tool-installer").setup({
            ensure_installed = {
                "stylua", "ruff", "prettier", "rustfmt",
                "clang-format", "shfmt", "ktlint", "google-java-format",
            },
            run_on_start = true,
        })
    end,
}
