--[[
NEOVIM CONFIGURATION
------------------------------------
Where to store these files:
  Linux/macOS: ~/.config/nvim/init.lua
  Windows:     ~/AppData/Local/nvim/init.lua

See README for configuring information.
--]]

vim.g.mapleader = ","
vim.g.maplocalleader = "\\"
vim.uv = vim.uv or vim.loop

-- Taken from folke: override vim.keymap.set
-- Default to silent, non-recursive keymaps
local orig_keymap_set = vim.keymap.set
---@param mode string|string[]            -- Mode: e.g. "n", "i", or {"n", "v"}
---@param lhs string                      -- Key combination (e.g. "<leader>f")
---@param rhs string|function             -- Function, string command, or Lua expression
---@param opts? table|vim.keymap.set.Opts -- Options table (include "desc" for which-key)
---@diagnostic disable-next-line: duplicate-set-field
vim.keymap.set = function(mode, lhs, rhs, opts)
  opts = opts or {}
  -- ~= false -> if not explicitly set to false, then set to true
  opts.noremap = opts.noremap ~= false
  opts.silent = opts.silent ~= false
  orig_keymap_set(mode, lhs, rhs, opts)
end

---@type vim.diagnostic.Opts
local diagnostic_opts = {
  update_in_insert = true,
  virtual_text = {
    spacing = 2,
    source = "if_many",
  },
  severity_sort = true,
  float = {
    border = "rounded",
    header = "",
    title = " Diagnostics ",
    source = "if_many",
  },
}
vim.diagnostic.config(diagnostic_opts)

-- Disable provider warnings
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

-- Hack to work to launch in any environment that may load the UI later (e.g. WSL starts a server)
vim.api.nvim_create_autocmd("UIEnter", {
  desc = "Load GUI specific options (e.g. Neovide)",
  callback = function()
    if vim.g.neovide then
      vim.o.guifont = "Geist Mono,Symbols Nerd Font Mono:h10"
      vim.opt.belloff:append("all")


      -- https://neovide.dev/faq.html#how-can-i-use-cmd-ccmd-v-to-copy-and-paste
      local ctrl_key = vim.fn.has("mac") == 1 and "<D-" or "<C-"
      vim.keymap.set("n",          ctrl_key .. "s>", ":w<CR>",      { desc = "Save" })
      vim.keymap.set({ "n", "v" }, ctrl_key .. "c>", '"+y',         { desc = "Copy to clipboard" })
      vim.keymap.set("n",          ctrl_key .. "v>", '"+P',         { desc = "Paste (normal)" })
      vim.keymap.set("v",          ctrl_key .. "v>", '"+P',         { desc = "Paste (visual)" })
      vim.keymap.set("c",          ctrl_key .. "v>", "<C-r>+",      { desc = "Paste (command)" })
      vim.keymap.set("i",          ctrl_key .. "v>", '<ESC>l"+Pli', { desc = "Paste (insert)" })
      vim.api.nvim_set_keymap("",  ctrl_key .. "v>", "+p<CR>", { noremap = true, silent = true })
      vim.api.nvim_set_keymap("!", ctrl_key .. "v>", "<C-R>+", { noremap = true, silent = true })
      vim.api.nvim_set_keymap("t", ctrl_key .. "v>", "<C-R>+", { noremap = true, silent = true })
      vim.api.nvim_set_keymap("v", ctrl_key .. "v>", "<C-R>+", { noremap = true, silent = true })

      -- Zoom in/out: https://neovide.dev/faq.html#how-can-i-dynamically-change-the-scale-at-runtime
      vim.g.neovide_scale_factor = 1.0
      local change_scale_factor = function(delta)
        vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
      end
      vim.keymap.set("n", "<C-=>", function() change_scale_factor(1.25) end,     { desc = "Increase font size" })
      vim.keymap.set("n", "<C-->", function() change_scale_factor(1 / 1.25) end, { desc = "Decrease font size" })

      vim.keymap.set("n", "<leader>uf", function()
        vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
      end, { desc = "[U]I: toggle [f]ullscreen" })

      vim.g.neovide_title_background_color = string.format("%x",
        vim.api.nvim_get_hl(0, { id = vim.api.nvim_get_hl_id_by_name("Normal") }).bg or 0x000000
      )
    end
  end,
})

-- Load core configurations in this order
require("core.options")
require("core.filetypes")
require("core.commands")
require("core.keymaps")
require("core.terminal")
require("core.lazy")
