-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '<C-b>', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    filesystem = {
      window = {
        width = 30,
        mappings = {
          ['<C-b>'] = 'close_window',
          ['<C-v>'] = 'open_vsplit',
        },
      },
      filtered_items = {
        visible = true,
        never_show = {
          '.git',
          '.DS_Store',
          '.history',
        },
      },
    },
  },
}
