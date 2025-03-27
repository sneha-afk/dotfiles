--[[
  Neovim Configuration Main Entry Point
  ------------------------------------
  File Locations:
    Linux/macOS: ~/.config/nvim/init.lua
    Windows:     ~/AppData/Local/nvim/init.lua

  Configuration Structure:
  ├── init.lua            - Main configuration entry point
  ├── lua/
  │   ├── core/           - Core Neovim settings
  │   │   ├── filetypes.lua - Filetype-specific configurations
  │   │   ├── keymaps.lua   - Keybindings and mappings
  │   │   ├── options.lua   - Neovim options and settings
  │   │   └── terminal.lua  - Terminal integration settings
  │   └── plugins/        - Plugin configurations
  │       ├── editor.lua    - Text editing enhancements
  │       ├── file_tree.lua - File explorer configurations
  │       ├── init.lua      - Plugin manager setup
  │       ├── lsp/          - Language Server Protocol
  │       │   ├── init.lua     - LSP core setup
  │       │   ├── keymaps.lua  - LSP-specific keybindings
  │       │   └── server_configs.lua - Server configurations
  │       ├── misc.lua      - Miscellaneous plugins
  │       └── ui.lua        - UI/visual customization
  └── stylua.toml         - Stylua formatter configuration
--]]

-- Set leader keys before any other configurations
vim.g.mapleader = ","
vim.g.maplocalleader = "\\"

-- Load core configurations
require "core.options"            -- Load first as it affects other modules
require "core.filetypes".setup()  -- Filetype detection and settings
require "core.keymaps"            -- Key mappings
require "core.terminal"           -- Terminal integration

-- Ask if plugins should be installed if not already
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
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
require "plugins.init"

-- Optional: Print loaded message for debugging
-- vim.notify("Neovim configuration loaded", vim.log.levels.INFO)
