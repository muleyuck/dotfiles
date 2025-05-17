-- ############# personal setting #################
vim.keymap.set('i', 'jj', '<ESC>', { noremap = true, silent = true })
vim.keymap.set('i', 'jk', '<ESC>', { noremap = true, silent = true })
vim.keymap.set('n', ':', ';')
vim.keymap.set('n', ';', ':')

-- ############# personal setting #################

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open diagnostic [E]rror list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mappin
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- vim: ts=2 sts=2 sw=2 et

-- ===================== Personal Mapping =====================

-- Buffer operation
vim.keymap.set('n', '<Tab>', '<CMD>bnext<CR>')
vim.keymap.set('n', '<S-Tab>', '<CMD>bprev<CR>')
vim.keymap.set('n', '<leader>be', '<CMD>:bufdo edit<CR>')

-- Tab operation
vim.keymap.set('n', '<C-S-h>', '<CMD>:tabprev<CR>')
vim.keymap.set('n', '<C-S-l>', '<CMD>:tabnext<CR>')
-- vim.keymap.set('n', '<S-t>', '<CMD>:tabnew<CR>')
vim.keymap.set('n', '<S-w>', '<CMD>:tabclose<CR>')

-- emacs keybind when insert mode
vim.keymap.set('i', '<C-d>', '<Del>')
vim.keymap.set('i', '<C-H>', '<BS>')
vim.keymap.set('i', '<C-a>', '<Home>')
vim.keymap.set('i', '<C-e>', '<End>')
vim.keymap.set('i', '<C-p>', '<Up>')
vim.keymap.set('i', '<C-n>', '<Down>')
vim.keymap.set('i', '<C-f>', '<Right>')
vim.keymap.set('i', '<C-b>', '<Left>')
vim.keymap.set('i', '<C-S-f>', '<S-Right>')
vim.keymap.set('i', '<C-S-b>', '<S-Left>')
vim.keymap.set('n', '<C-a>', '^')
vim.keymap.set('n', '<C-e>', '$')

vim.keymap.set('n', 's', '<CMD>w<CR>')
vim.keymap.set({ 'n', 'v' }, 'x', '"_x')

vim.keymap.set('n', 'q', '<nop>')
vim.keymap.set('n', '<C-i>', '<nop>')
vim.keymap.set('n', '<C-o>', '<nop>')
vim.keymap.set('i', '<C-r>', '<nop>')
-- Copilot
vim.keymap.set({'n','v'}, '<leader>cc', '<CMD>CopilotChat<CR>', { desc = 'Open Copilot Chat' })
vim.keymap.set('n','v'}, '<leader>ch', '<CMD>CopilotChatPrompt<CR>', { desc = 'Select Copilot Chat Prompt' })
