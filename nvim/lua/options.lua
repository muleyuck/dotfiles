-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '→ ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- vim: ts=2 sts=2 sw=2 et

-- テキストの折り返しを無効化
vim.opt.wrap = false

-- terraformはファイルを自動で認識しないので明示的に認識させる
vim.cmd 'autocmd BufNewFile,BufRead *.tf set filetype=terraform'

-- filetype毎のインデント幅
local filetype_tabstop = {
  lua = 2,
  markdown = 2,
  json = 2,
  yaml = 2,
  typescript = 2,
  typescriptreact = 2,
  javascript = 2,
  javascriptreact = 2,
  terraform = 2,
}
-- buffer
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
  pattern = '*',
  group = vim.api.nvim_create_augroup('buffer_set_options', {}),
  callback = function()
    -- swapfile作成を無効化
    vim.opt.swapfile = false
    -- tabをスペースに変換
    vim.opt.expandtab = true

    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('UserFileTypeConfig', { clear = true }),
      callback = function(args)
        local ftts = filetype_tabstop[args.match]
        --  tab幅
        if ftts then
          vim.opt.tabstop = ftts
          vim.opt.shiftwidth = ftts
        else
          vim.opt.tabstop = 4
          vim.opt.shiftwidth = 4
        end
      end,
    })
  end,
})
