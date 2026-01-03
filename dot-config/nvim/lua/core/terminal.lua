-- .config/nvim/lua/core/terminal.lua

local term_types = { "term://*", "toggleterm", "snacks_terminal" }

-- Set up blinking cursor for Windows terminal mode
if vim.fn.has("win32") == 1 then
  vim.opt.guicursor = table.concat({
    "n-v-c-sm:block-blinkwait500-blinkon500-blinkoff500", -- Normal/visual: block
    "i-ci-ve:ver25-blinkwait500-blinkon500-blinkoff500",  -- Insert: vertical bar
    "r-cr-o:hor20-blinkwait500-blinkon500-blinkoff500",   -- Replace: horizontal bar
    "a:blinkon500-blinkoff500",                           -- All modes: blink control
  }, ",")
end

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
