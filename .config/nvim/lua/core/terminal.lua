-- ===================================================================
-- Terminal Settings
-- ===================================================================
local function setup_terminal()
  vim.opt_local.number = false
  vim.opt_local.relativenumber = false
  vim.opt_local.signcolumn = 'no'
  vim.opt_local.cursorline = false

  vim.opt_local.buflisted = false  -- Don't show terminal buffers in buffer list
  vim.opt_local.swapfile = false   -- No swap files for terminals
  vim.opt_local.bufhidden = 'hide' -- Hide instead of unload when not visible

  vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { buffer = true })  -- Escape to normal mode
  vim.keymap.set('t', '<C-w>h', [[<C-\><C-n><C-w>h]], { buffer = true })  -- Window navigation
  vim.keymap.set('t', '<C-w>j', [[<C-\><C-n><C-w>j]], { buffer = true })
  vim.keymap.set('t', '<C-w>k', [[<C-\><C-n><C-w>k]], { buffer = true })
  vim.keymap.set('t', '<C-w>l', [[<C-\><C-n><C-w>l]], { buffer = true })

  -- Scrollback buffer size (only works for some terminal emulators)
  vim.cmd('set scrollback=10000')
end

vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = setup_terminal,
})

-- Windows Terminal Cursor Shaping
if vim.env.WT_SESSION then
  vim.opt.guicursor = {
    "n-v-c:block",    -- Normal/visual/command mode: block cursor
    "i-ci-ve:ver25",  -- Insert mode: vertical bar
    "r-cr:hor20",     -- Replace mode: horizontal bar
    "o:hor50"         -- Operator-pending mode: wider horizontal bar
  }
end
