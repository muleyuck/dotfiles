return {
  'nanotee/sqls.nvim',
  ft = { 'sql', 'mysql' },
  config = function()
    vim.lsp.enable 'sqls'
    vim.keymap.set('n', '<leader>qe', '<CMD>SqlsExecuteQuery<CR>', { silent = true })
    vim.keymap.set('n', '<leader>qs', '<CMD>SqlsShowSchemas<CR>', { silent = true })
    vim.keymap.set('n', '<leader>qd', '<CMD>SqlsSwitchDatabase<CR>', { silent = true })
    vim.keymap.set('n', '<leader>qc', '<CMD>SqlsSwitchConnection<CR>', { silent = true })
  end,
}
