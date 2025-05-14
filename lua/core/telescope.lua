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

