-- .config/nvim/lua/core/keymaps.lua

-- t for terminal, vt for vertical terminal
vim.keymap.set("n", "<leader>t", ":split | terminal<CR>i", {
  noremap = true,
  silent = true,
  desc = "Open horizontal terminal",
})
vim.keymap.set("n", "<leader>vt", ":vsplit | terminal<CR>i", {
  noremap = true,
  silent = true,
  desc = "Open vertical terminal",
})

-- Esc -> back to normal mode in terminal
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", {
  noremap = true,
  silent = true,
  desc = "Exit terminal mode",
})

vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit window" })
vim.keymap.set("n", "<leader>x", ":wq<CR>", { desc = "Save & quit" })
vim.keymap.set("n", "<leader>Q", ":qa<CR>", { desc = "Quit all windows" })
