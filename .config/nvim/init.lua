--[[
  NEOVIM CONFIGURATION
  ------------------------------------
  Where to store these files:
    Linux/macOS: ~/.config/nvim/init.lua
    Windows:     ~/AppData/Local/nvim/init.lua

  To install more LSPs, either globally install or add to the list at the top of plugins/lsp/init.lua,
  then configure at minimum a blank settings table {} in plugins/lsp/server_configs.lua

  ~/.config/nvim/
  ├── init.lua              - Main entry point: loads in core/ and plugins/ if desired
  └── lua/
      ├── core/
      │   ├── filetypes.lua - Filetype-specific settings
      │   ├── keymaps.lua   - Global keymaps
      │   ├── lazy.lua      - Sets up lazy.nvim
      │   ├── options.lua   - Neovim options (set vim.opt)
      │   └── terminal.lua  - Terminal configurations
      └── plugins/
          ├── editor.lua          - Text editing plugins (surround, comments, etc.)
          ├── file_tree.lua       - File navigation
          ├── git_plugins.lua     - Plugins for managing Git operations
          ├── helpers.lua         - Helpful plugins otherwise uncategorizable
          ├── lsp/                - Language Server Protocol
          │   ├── completions.lua - Completion and snippets settings
          │   ├── config.lua      - Global shared LSP configurations
          │   ├── init.lua        - Core LSP configuration
          │   ├── keymaps.lua     - LSP keybindings
          │   └── server_configs.lua - Language-specific setups
          ├── startup.lua   - Dashboard/startup screen
          └── ui.lua        - Interface customization (statusline, colorscheme, etc.)
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
require "core.lazy"
