-- .config/nvim/lua/core/terminal.lua

local term_types = { "term://*", "toggleterm", "snacks_terminal" }

vim.api.nvim_create_autocmd("TermOpen", {
  pattern = term_types,
  callback = function()
    local opt = vim.opt_local
    opt.number = false         -- Disable line numbers
    opt.relativenumber = false -- Disable relative numbers
    opt.signcolumn = "no"      -- Hide sign column
    opt.cursorline = false     -- Disable current line highlight
    opt.buflisted = false      -- Exclude from buffer list
    opt.swapfile = false       -- No swap files for terminals
    opt.bufhidden = "hide"     -- Hide instead of unload when not visible
    opt.scrollback = 10000     -- Increase scrollback history
  end,
  desc = "Setup terminal buffer options and keymaps",
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = term_types,
  callback = function() vim.cmd("startinsert") end,
  desc = "Auto-enter insert mode when focusing terminal",
})
