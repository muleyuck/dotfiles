return {
  'petertriho/nvim-scrollbar',
  config = function()
    require('scrollbar').setup {
      exclude_filetypes = {
        'Neotree',
      },
    }
  end,
}
