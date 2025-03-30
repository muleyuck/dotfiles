return {
  'EdenEast/nightfox.nvim',
  priority = 1000,
  init = function()
    require('nightfox').setup {
      options = {
        transparent = true, -- Disable setting background
        styles = {
          comments = 'italic,nocombine', -- Value is any valid attr-list value `:help attr-list`
          conditionals = 'NONE',
          constants = 'italic,nocombine',
          functions = 'bold,nocombine',
          keywords = 'NONE',
          numbers = 'NONE',
          operators = 'NONE',
          strings = 'NONE',
          types = 'italic,bold,nocombine',
          variables = 'NONE',
        },
        inverse = { -- Inverse highlight for different types
          match_paren = false,
          visual = true,
          search = false,
        },
      },
      specs = {
        nordfox = {
          diff = {
            add = '#404F27',
            change = '#2E3C24',
            delete = '#631A1A',
            text = '#404F27',
          },
        },
      },
    }
    -- Load the colorscheme here.
    -- Like many other themes, this one has different styles, and you could load
    -- any other, such as 'nightfox', 'dayfox', 'dawnfox', 'duskfox', 'nordfox', 'terafox', 'carbonfox'
    vim.cmd.colorscheme 'nordfox'
    -- You can configure highlights by doing something like:
    vim.cmd.hi 'Comment gui=none'
  end,
}
