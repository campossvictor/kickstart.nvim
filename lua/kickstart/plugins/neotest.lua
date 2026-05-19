-- neotest: run tests directly inside neovim

vim.pack.add {
  'https://github.com/nvim-neotest/neotest',
  'https://github.com/nvim-neotest/nvim-nio',
  'https://github.com/nvim-neotest/neotest-python',
}

require('neotest').setup {
  adapters = {
    require('neotest-python') {
      dap = { justMyCode = false },
      runner = 'pytest',
      python = function()
        local venv = os.getenv 'VIRTUAL_ENV' or os.getenv 'CONDA_PREFIX'
        if venv then return venv .. '/bin/python' end
        local cwd_venv = vim.fn.getcwd() .. '/.venv/bin/python'
        if vim.fn.executable(cwd_venv) == 1 then return cwd_venv end
        return 'python'
      end,
    },
  },
}

vim.keymap.set('n', '<leader>tt', function() require('neotest').run.run() end, { desc = '[T]est: Run nearest' })
vim.keymap.set('n', '<leader>tf', function() require('neotest').run.run(vim.fn.expand '%') end, { desc = '[T]est: Run [F]ile' })
vim.keymap.set('n', '<leader>td', function() require('neotest').run.run { strategy = 'dap' } end, { desc = '[T]est: [D]ebug nearest' })
vim.keymap.set('n', '<leader>ts', function() require('neotest').summary.toggle() end, { desc = '[T]est: Toggle [S]ummary' })
vim.keymap.set('n', '<leader>to', function() require('neotest').output_panel.toggle() end, { desc = '[T]est: Toggle [O]utput' })
vim.keymap.set('n', ']t', function() require('neotest').jump.next { status = 'failed' } end, { desc = 'Next failed test' })
vim.keymap.set('n', '[t', function() require('neotest').jump.prev { status = 'failed' } end, { desc = 'Prev failed test' })
