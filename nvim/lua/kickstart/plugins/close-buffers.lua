return {
  'kazhala/close-buffers.nvim',
  vim.api.nvim_set_keymap('n', '<leader>bh', [[<CMD>lua require('close_buffers').delete({type = 'hidden'})<CR>]], { noremap = true, silent = true }),
  vim.api.nvim_set_keymap('n', '<leader>bn', [[<CMD>lua require('close_buffers').delete({type = 'nameless'})<CR>]], { noremap = true, silent = true }),
  vim.api.nvim_set_keymap('n', '<leader>bc', [[<CMD>lua require('close_buffers').delete({type = 'this'})<CR>]], { noremap = true, silent = true }),
}
