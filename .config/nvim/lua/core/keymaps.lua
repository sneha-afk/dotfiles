-- ===================================================================
-- Leader Key Setup
-- ===================================================================
vim.g.mapleader = ","  -- Set leader key to comma
vim.g.maplocalleader = "\\"

-- Safety check for unmapped leader keys
vim.keymap.set("n", "<leader>", function()
  vim.notify("Unmapped leader key", vim.log.levels.ERROR)
end, { desc = "Fallback for unmapped leader keys" })

-- ===================================================================
-- Plugin Keymaps
-- ===================================================================
-- n for opening file tree
vim.keymap.set("n", "<leader>n", ":NvimTreeFocus<CR>", { 
  noremap = true, 
  silent = true,
  desc = "Toggle file explorer" 
})

-- t for terminal, vt for vertical terminal
vim.keymap.set('n', '<leader>t', ':split | terminal<CR>i', { 
  noremap = true, 
  silent = true,
  desc = "Open horizontal terminal" 
})
vim.keymap.set('n', '<leader>vt', ':vsplit | terminal<CR>i', { 
  noremap = true, 
  silent = true,
  desc = "Open vertical terminal" 
})

-- Esc -> back to normal mode in terminal
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", {
  noremap = true, 
  silent = true,
  desc = "Exit terminal mode" 
})
