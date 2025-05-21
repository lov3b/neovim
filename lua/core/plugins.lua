require('lazy').setup({
    { 'nvim-lua/plenary.nvim' },
    { 'nvim-lua/popup.nvim' },

    {
        "catppuccin/nvim",
        name     = "catppuccin",
        lazy     = false,
        priority = 1000,

        -- run *before* loading the plugin so that `vim.opt.background`
        -- is already set when `require("catppuccin").setup()` runs
        init = function()
            local hour = tonumber(os.date("%H"))
            vim.opt.background = (hour >= 19 or hour < 7)
            and "dark"
            or "light"
        end,

        -- these options will be fed directly to `require("catppuccin").setup(opts)`
        opts = {
            -- let the plugin pick latte vs. mocha based on `&background`
            flavour = "auto",
            background = {
                light = "latte",
                dark  = "mocha",
            },
            transparent_background = false,
            show_end_of_buffer    = false,
            term_colors           = false,

            -- rely on the default_integrations (which includes native LSP highlights),
            -- and only explicitly turn on the ones you really want here.
            default_integrations = true,
            integrations = {
                cmp        = true,
                gitsigns   = true,
                nvimtree   = true,
                telescope  = true,
                treesitter = true,
                -- no nested tables here → no more `pairs()` on strings!
            },
        },

        -- finally, load it and apply the colorscheme
        config = function(_, opts)
            require("catppuccin").setup(opts)
            vim.cmd.colorscheme("catppuccin")
        end,
    },



    -- project management + telescope extension
    {
        'ahmedkhalf/project.nvim',
        config = function()
            require('project_nvim').setup {}
            require('telescope').load_extension('projects')
        end,
    },

    -- Telescope
    {
        'nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config      = function() 
            local telescope = require('telescope')
            local actions   = require('telescope.actions')
            telescope.setup {
                defaults = {
                    prompt_prefix = '❯ ',
                    selection_caret = '➤ ',
                    mappings = {
                        i = {
                            ['<C-b>'] = actions.preview_scrolling_up,
                            ['<C-f>'] = actions.preview_scrolling_down,
                        },
                    },
                },
            }
        end,
    },
    {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond  = function() return vim.fn.executable('make') == 1 end,
    },
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function() require('conf.treesitter') end,
    },

    -- Mason & LSP installer
    { 'williamboman/mason.nvim', config = true },
    {
        'williamboman/mason-lspconfig.nvim',
        dependencies = { 'williamboman/mason.nvim' },
        config       = function() require('core.lsp') end,
    },
    { 'neovim/nvim-lspconfig' },

    -- Completion
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'L3MON4D3/LuaSnip',
        },
        config = function()
            local cmp = require('cmp')
            cmp.setup {
                snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end },
                mapping = cmp.mapping.preset.insert {
                    ['<CR>'] = cmp.mapping.confirm { select = true },
                    ['<C-Space>'] = cmp.mapping.complete(),
                },
                sources = {
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                },
            }
        end,
    },
    { 'L3MON4D3/LuaSnip' },


    -- This is a lot of headache
    --  {
    --    'jose-elias-alvarez/null-ls.nvim',
    --    dependencies = { 'mason.nvim' },
    --    config       = function() require('core.null_ls') end,
    --  },
    { 'windwp/nvim-autopairs',  config = function() require('core.autopairs') end },
    { 'numToStr/Comment.nvim',   opts   = {} },
    { 'lewis6991/gitsigns.nvim', opts   = { signs = { add='+', change='~', delete='_' } } },

    { 'folke/which-key.nvim', opts = {} },

    {
        'nvim-lualine/lualine.nvim',
        opts = function() require('conf.statusline') end,
    },

    {
        "goolord/alpha-nvim",
        -- dependencies = { 'echasnovski/mini.icons' },
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            local startify = require("alpha.themes.startify")
            -- available: devicons, mini
            startify.file_icons.provider = "devicons"
            require("alpha").setup(
                startify.config
            )
        end,
    },
})

