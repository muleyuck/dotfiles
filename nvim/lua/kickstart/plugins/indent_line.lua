return {
  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    -- opts = function(_, opts)
    --   -- Other blankline configuration hereby
    --   return require('indent-rainbowline').make_opts(opts)
    -- end,
    -- dependencies = {
    --   'TheGLander/indent-rainbowline.nvim',
    -- },
    config = function()
      local highlight = {
        'RainbowRed',
        'RainbowYellow',
        'RainbowBlue',
        'RainbowOrange',
        'RainbowGreen',
        'RainbowViolet',
        'RainbowCyan',
      }

      local hooks = require 'ibl.hooks'
      -- create the highlight groups in the highlight setup hook, so they are reset
      -- every time the colorscheme changes
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        -- #e06c75 #e0b4b7 #e0878e #e05a65 #e02d3c #e00013
        vim.api.nvim_set_hl(0, 'RainbowRed', { fg = '#E0B4B7' })
        -- #e5c07b #e6d5b8 #e6c58a #e6b55c #e6a52e #e69500
        vim.api.nvim_set_hl(0, 'RainbowYellow', { fg = '#E6D5B8' })
        -- #61afef #c0daf0 #90c5f0 #60aff0 #3099f0 #0084f0
        vim.api.nvim_set_hl(0, 'RainbowBlue', { fg = '#C0DAF0' })
        -- #d19a66 #d1bba7 #d1a67d #d19054 #d17b2a #d16500
        vim.api.nvim_set_hl(0, 'RainbowOrange', { fg = '#D1BBA7' })
        -- #98c379 #abc29b #95c274 #7ec24e #67c227 #51c200
        vim.api.nvim_set_hl(0, 'RainbowGreen', { fg = '#ABC29B' })
        -- #c678dd #d3b1de #c985de #bf59de #b42cde #aa00de
        vim.api.nvim_set_hl(0, 'RainbowViolet', { fg = '#D3B1DE' })
        -- #56b6c2 #9bbdc2 #74b9c2 #4eb4c2 #27b0c2 #00abc2
        vim.api.nvim_set_hl(0, 'RainbowCyan', { fg = '#9BBDC2' })
      end)
      require('ibl').setup {
        scope = {
          -- enabled = false,
        },
        indent = {
          -- highlight = highlight,
          -- char = '▏',
        },
      }
    end,
  },
}
