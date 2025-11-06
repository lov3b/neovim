require('nvim-treesitter.configs').setup {
    ensure_installed = {
        'lua','python','javascript','typescript',
        'go','rust','c','cpp','vim', 'java',
        'kotlin'
    },
    highlight = { enable = true },
    indent    = { enable = true },
    textobjects = {
        select = {
            enable    = true,
            lookahead = true,
            keymaps   = {
                ['af'] = '@function.outer',
                ['if'] = '@function.inner',
            },
        },
        move = {
            enable          = true,
            set_jumps       = true,
            goto_next_start = { [']m'] = '@function.outer' },
            goto_previous_start = { ['[m'] = '@function.outer' },
        },
    },
}

