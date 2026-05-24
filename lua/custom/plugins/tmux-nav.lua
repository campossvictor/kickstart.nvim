local function navigate(dir)
  local cur_win = vim.fn.winnr()
  vim.cmd('wincmd ' .. dir)
  if cur_win == vim.fn.winnr() and vim.env.TMUX then
    local tmux_dir = { h = 'L', j = 'D', k = 'U', l = 'R' }
    vim.fn.system('tmux select-pane -' .. tmux_dir[dir])
  end
end

vim.keymap.set('n', '<C-h>', function() navigate('h') end, { desc = 'Navigate left (nvim/tmux)' })
vim.keymap.set('n', '<C-j>', function() navigate('j') end, { desc = 'Navigate down (nvim/tmux)' })
vim.keymap.set('n', '<C-k>', function() navigate('k') end, { desc = 'Navigate up (nvim/tmux)' })
vim.keymap.set('n', '<C-l>', function() navigate('l') end, { desc = 'Navigate right (nvim/tmux)' })
