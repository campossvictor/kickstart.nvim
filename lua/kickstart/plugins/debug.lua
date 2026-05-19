-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

vim.pack.add {
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/rcarriga/nvim-dap-ui',
  'https://github.com/nvim-neotest/nvim-nio',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/jay-babu/mason-nvim-dap.nvim',
  'https://github.com/mfussenegger/nvim-dap-python',
}

-- Basic debugging keymaps, feel free to change to your liking!
vim.keymap.set('n', '<F5>', function() require('dap').continue() end, { desc = 'Debug: Start/Continue' })
vim.keymap.set('n', '<F1>', function() require('dap').step_into() end, { desc = 'Debug: Step Into' })
vim.keymap.set('n', '<F2>', function() require('dap').step_over() end, { desc = 'Debug: Step Over' })
vim.keymap.set('n', '<F3>', function() require('dap').step_out() end, { desc = 'Debug: Step Out' })
vim.keymap.set('n', '<leader>db', function() require('dap').toggle_breakpoint() end, { desc = '[D]ebug: Toggle [B]reakpoint' })
vim.keymap.set('n', '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, { desc = '[D]ebug: Set Conditional [B]reakpoint' })
vim.keymap.set('n', '<leader>dc', function() require('dap').continue() end, { desc = '[D]ebug: [C]ontinue' })
vim.keymap.set('n', '<leader>du', function() require('dapui').toggle() end, { desc = '[D]ebug: Toggle [U]I' })

local dap = require 'dap'
local dapui = require 'dapui'

require('mason-nvim-dap').setup {
  -- Makes a best effort to setup the various debuggers with
  -- reasonable debug configurations
  automatic_installation = true,

  -- You can provide additional configuration to the handlers,
  -- see mason-nvim-dap README for more information
  handlers = {},

  -- You'll need to check that you have the required things installed
  -- online, please don't ask me how to install them :)
  ensure_installed = {
    'debugpy',
  },
}

-- Dap UI setup
-- For more information, see |:help nvim-dap-ui|
---@diagnostic disable-next-line: missing-fields
dapui.setup {
  -- Set icons to characters that are more likely to work in every terminal.
  --    Feel free to remove or use ones that you like more! :)
  --    Don't feel like these are good choices.
  icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
  ---@diagnostic disable-next-line: missing-fields
  controls = {
    icons = {
      pause = '⏸',
      play = '▶',
      step_into = '⏎',
      step_over = '⏭',
      step_out = '⏮',
      step_back = 'b',
      run_last = '▶▶',
      terminate = '⏹',
      disconnect = '⏏',
    },
  },
}

-- Highlight da linha atual em execução (fundo amarelo escuro)
vim.api.nvim_set_hl(0, 'DapStoppedLine', { bg = '#3d3400' })
vim.fn.sign_define('DapStopped', { text = '▶', texthl = 'DiagnosticWarn', linehl = 'DapStoppedLine', numhl = 'DiagnosticWarn' })
vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DiagnosticError', numhl = 'DiagnosticError' })
vim.fn.sign_define('DapBreakpointCondition', { text = '◉', texthl = 'DiagnosticWarn', numhl = 'DiagnosticWarn' })

dap.listeners.after.event_initialized['dapui_config'] = dapui.open
dap.listeners.before.event_terminated['dapui_config'] = dapui.close
dap.listeners.before.event_exited['dapui_config'] = dapui.close

-- Install Python specific config
-- O adapter sempre usa o python do Mason (que tem debugpy instalado).
-- O python do projeto (venv) é usado apenas para rodar o script debugado.
local mason_python = vim.fn.stdpath 'data' .. '/mason/packages/debugpy/venv/bin/python'

local function get_project_python()
  local venv = os.getenv 'VIRTUAL_ENV' or os.getenv 'CONDA_PREFIX'
  if venv then return venv .. '/bin/python' end
  local cwd_venv = vim.fn.getcwd() .. '/.venv/bin/python'
  if vim.fn.executable(cwd_venv) == 1 then return cwd_venv end
  return mason_python
end

require('dap-python').setup(mason_python)
require('dap-python').test_runner = 'pytest'

-- Patch all Python configurations to use project venv and integrated terminal
for _, config in ipairs(dap.configurations.python or {}) do
  config.pythonPath = get_project_python
  config.justMyCode = true
  config.console = 'integratedTerminal'
end
