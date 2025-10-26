return {

  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'
      lint.linters_by_ft = {
        -- markdown = { 'markdownlint' },
        -- javascript = { 'biomejs', 'eslint' },
        -- javascriptreact = { 'biomejs', 'eslint' },
        -- typescript = { 'biomejs', 'eslint' },
        -- typescriptreact = { 'biomejs', 'eslint' },
        python = { 'mypy' }, -- NOTE: require install pydantic (https://kobe-kosen-robotics.org/folder/Wiki/docs/build/html/user_guide/linux/astronvim.html#lint)
      }

      -- Function to find the appropriate mypy executable
      local function get_mypy_path()
        -- Try VIRTUAL_ENV environment variable
        local venv = os.getenv 'VIRTUAL_ENV'
        if venv and venv ~= '' then
          local venv_mypy = venv .. '/bin/mypy'
          if vim.fn.executable(venv_mypy) == 1 then
            return venv_mypy
          end
        end

        -- Try .venv in current directory
        local cwd = vim.fn.getcwd()
        local venv_mypy = cwd .. '/.venv/bin/mypy'
        if vim.fn.executable(venv_mypy) == 1 then
          return venv_mypy
        end

        -- Try .venv in git root
        local git_root_cmd = vim.fn.systemlist 'git rev-parse --show-toplevel 2>/dev/null'
        if git_root_cmd and #git_root_cmd > 0 then
          local git_root = git_root_cmd[1]
          venv_mypy = git_root .. '/.venv/bin/mypy'
          if vim.fn.executable(venv_mypy) == 1 then
            return venv_mypy
          end
        end

        -- Fallback to system mypy
        return 'mypy'
      end

      -- Configure mypy to use virtual environment
      -- Start with default mypy linter and override cmd
      lint.linters.mypy.cmd = get_mypy_path()

      -- Update mypy path when entering Python files or changing directory
      vim.api.nvim_create_autocmd({ 'BufEnter', 'DirChanged' }, {
        pattern = '*.py',
        callback = function()
          lint.linters.mypy.cmd = get_mypy_path()
        end,
      })

      -- To allow other plugins to add linters to require('lint').linters_by_ft,
      -- instead set linters_by_ft like this:
      -- lint.linters_by_ft = lint.linters_by_ft or {}
      -- lint.linters_by_ft['markdown'] = { 'markdownlint' }
      --
      -- However, note that this will enable a set of default linters,
      -- which will cause errors unless these tools are available:
      -- {
      --   clojure = { "clj-kondo" },
      --   dockerfile = { "hadolint" },
      --   inko = { "inko" },
      --   janet = { "janet" },
      --   json = { "jsonlint" },
      --   markdown = { "vale" },
      --   rst = { "vale" },
      --   ruby = { "ruby" },
      --   terraform = { "tflint" },
      --   text = { "vale" }
      -- }
      --
      -- You can disable the default linters by setting their filetypes to nil:
      -- lint.linters_by_ft['clojure'] = nil
      -- lint.linters_by_ft['dockerfile'] = nil
      -- lint.linters_by_ft['inko'] = nil
      -- lint.linters_by_ft['janet'] = nil
      -- lint.linters_by_ft['json'] = nil
      -- lint.linters_by_ft['markdown'] = nil
      -- lint.linters_by_ft['rst'] = nil
      -- lint.linters_by_ft['ruby'] = nil
      -- lint.linters_by_ft['terraform'] = nil
      -- lint.linters_by_ft['text'] = nil

      -- Create autocommand which carries out the actual linting
      -- on the specified events.
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
