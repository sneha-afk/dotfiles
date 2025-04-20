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

-- Load core configurations in this order
require("core.options")
require("core.filetypes")
require("core.autocmds")
require("core.keymaps")
require("core.terminal")

-- Setup diagnostics
vim.diagnostic.config(
---@type vim.diagnostic.Opts
  {
    update_in_insert = true,
    virtual_text = {
      spacing = 4,
      source = "if_many",
    },
    severity_sort = true,
    float = {
      border = "rounded",
      header = "",
      title = " Diagnostics "
    },
  }
)

-- Ask if plugins should be installed if not already
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.api.nvim_echo({
    { "Lazy.nvim not installed.\n", "WarningMsg" },
    { "Load plugin system? [y/N] ", "Question" },
  }, true, {})

  local input = vim.fn.getcharstr()
  if input:lower() ~= "y" then
    vim.api.nvim_echo({
      { "Plugin system disabled.\n",            "WarningMsg" },
      { "Run :Lazy bootstrap to enable later.", "MoreMsg" },
    }, true, {})
    return
  end
end

-- Initialize plugin system
require "core.lazy"
