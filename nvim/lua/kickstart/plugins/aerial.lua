return {
  'stevearc/aerial.nvim',
  opts = {
    layout = {
      default_direction = 'float',
    },
    float = {
      relative = 'win',
    },
    -- on_attach = function(bufnr)
    --   -- Jump forwards/backwards with '{' and '}'
    --   vim.keymap.set('n', '<C-p>', '<cmd>AerialPrev<CR>', { buffer = bufnr })
    --   vim.keymap.set('n', '<C-n>', '<cmd>AerialNext<CR>', { buffer = bufnr })
    -- end,
  },
  -- Optional dependencies
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
  },
  -- You probably also want to set a keymap to toggle aerial
  vim.keymap.set('n', '<leader>a', '<CMD>AerialToggle<CR>'),
  vim.keymap.set('n', '<ESC><ESC>', '<CMD>AerialClose<CR>'),
}
