--[[
sneha's neovim config
------------------------------------
  Linux:    ~/.config/nvim/init.lua
  Windows:  ~/AppData/Local/nvim/init.lua
--]]
vim.loader.enable()

vim.g.mapleader = ","
vim.g.maplocalleader = "\\"
vim.uv = vim.uv or vim.loop

vim.g.is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1

if vim.g.is_windows then
  vim.opt.shell = "powershell"
  vim.opt.shellcmdflag = "-NoLogo -ExecutionPolicy RemoteSigned -Command"
end

-- Swap out pickers and any plugins using them
vim.g.picker_source = "folke/snacks.nvim"

-- Should (non-essential) icons be used?
vim.g.use_icons = true

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

-- Disable provider warnings
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

-- Load core configurations in this order
require("core.options")
require("core.filetypes")
require("core.commands")
require("core.keymaps")
require("core.terminal")
require("core.highlights")
require("core.lazy")

-- Hack to work to launch in any environment that may load the UI later (e.g. WSL starts a server)
vim.api.nvim_create_autocmd("UIEnter", {
  desc = "Load GUI specific options (e.g. Neovide)",
  callback = function()
    if vim.g.neovide then
      require("core.neovide")
    end
  end,
})
