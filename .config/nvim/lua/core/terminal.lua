-- .config/nvim/lua/core/terminal.lua

local function setup_terminal()
  local opt = vim.opt_local
  opt.number = false          -- Disable line numbers
  opt.relativenumber = false  -- Disable relative numbers
  opt.signcolumn = "no"       -- Hide sign column
  opt.cursorline = false      -- Disable current line highlight
  opt.buflisted = false       -- Exclude from buffer list
  opt.swapfile = false        -- No swap files for terminals
  opt.bufhidden = "hide"      -- Hide instead of unload when not visible
  opt.scrollback = 10000      -- Increase scrollback history

  local keymaps = {
    -- Basic terminal control
    ["<Esc>"] = [[<C-\><C-n>]],            -- Escape to normal mode
    ["<C-c>"] = [[<C-\><C-n>]],            -- Alternate escape sequence

    -- Window navigation
    ["<C-w>h"] = [[<C-\><C-n><C-w>h]],     -- Move left
    ["<C-w>j"] = [[<C-\><C-n><C-w>j]],     -- Move down
    ["<C-w>k"] = [[<C-\><C-n><C-w>k]],     -- Move up
    ["<C-w>l"] = [[<C-\><C-n><C-w>l]],     -- Move right

    -- Terminal management
    ["<C-w>N"] = [[<C-\><C-n>:q<CR>]],     -- Close terminal
    ["<C-w>_"] = [[<C-\><C-n><C-w>_]],     -- Maximize height
    ["<C-w>|"] = [[<C-\><C-n><C-w>|]],     -- Maximize width

    -- Scrolling
    ["<C-u>"] = [[<C-\><C-n><C-u>]],       -- Half page up
    ["<C-d>"] = [[<C-\><C-n><C-d>]],       -- Half page down
  }

  for key, cmd in pairs(keymaps) do
    vim.keymap.set("t", key, cmd, { buffer = true, silent = true })
  end

  -- Auto-insert mode when entering terminal
  vim.cmd("startinsert")
end

vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "term://*",
  callback = setup_terminal,
  desc = "Setup terminal buffer options and keymaps",
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "term://*",
  callback = function()
    vim.cmd("startinsert")
  end,
  desc = "Auto-enter insert mode when focusing terminal",
})

-- ===================================================================
-- Windows Terminal Integration
-- ===================================================================
if vim.env.WT_SESSION then
  vim.opt.guicursor = table.concat({
    "n-v-c-sm:block-blinkwait500-blinkon500-blinkoff500",     -- Normal/visual mode: solid block
    "i-ci-ve:ver25-blinkwait500-blinkon500-blinkoff500",      -- Insert mode: vertical bar
    "r-cr-o:hor20-blinkwait500-blinkon500-blinkoff500",       -- Replace mode: horizontal bar
    "a:blinkon500-blinkoff500",                               -- All modes: blinking control
  }, ",")
end
