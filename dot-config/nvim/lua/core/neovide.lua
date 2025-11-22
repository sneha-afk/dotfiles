-- .config/nvim/lua/core/neovide.lua
-- Assumes vim.g.neovide check is done before loading this file
-- See: https://neovide.dev/configuration.html

vim.opt.belloff:append("all")

-- Remember window size across sessions
vim.g.neovide_remember_window_size = true

-- Match title bar to current colorscheme background
vim.g.neovide_title_background_color = string.format("%x",
  vim.api.nvim_get_hl(0, { id = vim.api.nvim_get_hl_id_by_name("Normal") }).bg or 0x000000
)

vim.g.neovide_refresh_rate = 55
vim.g.neovide_refresh_rate_idle = 5
vim.g.neovide_no_idle = false

-- ============================================================
-- https://neovide.dev/faq.html#how-can-i-use-cmd-ccmd-v-to-copy-and-paste
local ctrl_key = vim.fn.has("mac") == 1 and "<D-" or "<C-"
vim.keymap.set("n",          ctrl_key .. "s>", ":w<CR>",      { desc = "Save" })
vim.keymap.set({ "n", "v" }, ctrl_key .. "c>", '"+y',         { desc = "Copy to clipboard" })
vim.keymap.set("n",          ctrl_key .. "v>", '"+P',         { desc = "Paste (normal)" })
vim.keymap.set("v",          ctrl_key .. "v>", '"+P',         { desc = "Paste (visual)" })
vim.keymap.set("c",          ctrl_key .. "v>", "<C-r>+",      { desc = "Paste (command)" })
vim.keymap.set("i",          ctrl_key .. "v>", '<ESC>l"+Pli', { desc = "Paste (insert)" })
vim.api.nvim_set_keymap("",  ctrl_key .. "v>", "+p<CR>",          { noremap = true, silent = true })
vim.api.nvim_set_keymap("!", ctrl_key .. "v>", "<C-R>+",          { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", ctrl_key .. "v>", '<C-\\><C-n>"+Pi', { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", ctrl_key .. "v>", "<C-R>+",          { noremap = true, silent = true })

vim.g.neovide_ime_enabled = false

-- ============================================================
-- Zoom in/out: https://neovide.dev/faq.html#how-can-i-dynamically-change-the-scale-at-runtime
vim.g.neovide_scale_factor = 1.0
local change_scale_factor = function(delta)
  vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
  vim.notify(string.format("Scale factor: %.2f", vim.g.neovide_scale_factor), vim.log.levels.INFO)
end
vim.keymap.set("n", "<C-=>", function() change_scale_factor(1.25) end,     { desc = "Increase font size" })
vim.keymap.set("n", "<C-->", function() change_scale_factor(1 / 1.25) end, { desc = "Decrease font size" })

local toggle_fullscreen = function()
  vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
end
vim.keymap.set({ "n", "i", "v", "t" }, "<leader>uf", toggle_fullscreen, { desc = "[U]I: toggle [f]ullscreen" })
vim.keymap.set({ "n", "i", "v", "t" }, "<F11>",      toggle_fullscreen, { silent = true })

vim.keymap.set({ "n", "i", "v", "t" }, "<leader>uP", function()
  vim.g.neovide_profiler = not vim.g.neovide_profiler
end, { desc = "[U]I: toggle [P]rofiler" })
