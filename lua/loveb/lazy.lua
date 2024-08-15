require('loveb.nightTime')

require('lazy').setup({
  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

  {
    'neovim/nvim-lspconfig', -- LSP Configuration & Plugins
    opts = {
      inlay_hints = { enabled = true },
    },
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim config = true },
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim',       tag = 'legacy', opts = {} },
      'folke/neodev.nvim', -- Additional lua configuration, makes nvim stuff amazing!
    },
  },

  {
    'hrsh7th/nvim-cmp',               -- Autocompletion
    dependencies = {
      'L3MON4D3/LuaSnip',             -- Snippet Engine & its associated nvim-cmp source
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',         -- Adds LSP completion capabilities
      'rafamadriz/friendly-snippets', -- Adds a number of user-friendly snippets
    },
  },

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim',  opts = {} },
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        vim.keymap.set('n', '<leader>gp', require('gitsigns').prev_hunk,
          { buffer = bufnr, desc = '[G]o to [P]revious Hunk' })
        vim.keymap.set('n', '<leader>gn', require('gitsigns').next_hunk, { buffer = bufnr, desc = '[G]o to [N]ext Hunk' })
        vim.keymap.set('n', '<leader>ph', require('gitsigns').preview_hunk, { buffer = bufnr, desc = '[P]review [H]unk' })
      end,
    },
  },

  {
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
    config = function()
      require("gruvbox").setup({
        undercurl = false,
        underline = false,
        bold = true,
        italic = {
          strings = false,
          comments = true,
          operators = false,
          folds = true,
        },
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        invert_intend_guides = false,
        inverse = true, -- invert background for search, diffs, statuslines and errors
        contrast = "",  -- can be "hard", "soft" or empty string
        palette_overrides = {},
        overrides = {},
        dim_inactive = false,
        transparent_mode = false,
      })
      vim.o.background = isNightTime() and "dark" or "light";
      vim.cmd.colorscheme 'gruvbox';
    end,
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        icons_enabled = false,
        theme = 'gruvbox',
        component_separators = '|',
        section_separators = '',
      },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    },
    opts = {
      reveal = true,
    }
  },

  {
    'lukas-reineke/indent-blankline.nvim',
    version = 'v3.*',
    event = 'BufReadPost',
    config = function()
      require('ibl').setup {
        indent = { char = '│' },
        scope = { enabled = false },
      }
    end,
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },

  require 'loveb.autoformat',
  -- require 'kickstart.plugins.debug',
}, {})
