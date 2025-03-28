--[[
  NEOVIM CONFIGURATION
  ------------------------------------
  File Locations:
    Linux/macOS: ~/.config/nvim/init.lua
    Windows:     ~/AppData/Local/nvim/init.lua

  ~/.config/nvim/
  ├── init.lua              - Main configuration entry point
  └── lua/
      ├── core/             - Core Neovim settings
      │   ├── filetypes.lua - Filetype detection
      │   ├── keymaps.lua   - Key mappings
      │   ├── options.lua   - Editor settings
      │   └── terminal.lua  - Terminal integration
      └── plugins/          - Plugin configurations
          ├── editor.lua    - Editing enhancements
          ├── file_tree.lua - File navigation
          ├── init.lua      - Plugin manager setup
          ├── lsp/          - Language Server Protocol
          │   ├── completions.lua - Completion settings
          │   ├── config.lua      - Common LSP configurations
          │   ├── init.lua        - Core LSP configuration
          │   ├── keymaps.lua     - LSP keybindings
          │   └── server_configs.lua - Language-specific setups
          ├── startup.lua   - Startup screen or initial configurations
          └── ui.lua        - Interface customization
--]]

vim.g.mapleader = ","
vim.g.maplocalleader = "\\"

-- Load core configurations
require "core.options"           -- Load first as it affects other modules
require "core.filetypes".setup() -- Filetype detection and settings
require "core.keymaps".setup()   -- Key mappings
require "core.terminal"          -- Terminal integration

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
