--[[
NEOVIM CONFIGURATION
------------------------------------
Where to store these files:
  Linux/macOS: ~/.config/nvim/init.lua
  Windows:     ~/AppData/Local/nvim/init.lua

To register a new LSP, configure at minimum a blank settings table {} in
  plugins/lsp/server_configs.lua, i.e gopls = {}. Defaults are taken from nvim-lspconfig.
Either globally install the LSP (ensure it is in PATH), or use Mason (can also add to the
  list at the top of plugins/lsp/init.lua)

~/.config/nvim/
├── init.lua
└── lua/
    ├── core/
    │   ├── autocmds.lua        - Autocommands to enable globally
    │   ├── filetypes.lua       - Filetype-specific settings
    │   ├── keymaps.lua         - Global keymaps
    │   ├── lazy.lua            - Sets up lazy.nvim plugin manager
    │   ├── options.lua         - Neovim options (vim.opt settings)
    │   └── terminal.lua        - Terminal configurations
    └── plugins/
        ├── helpers.lua         - Utility plugins (commenting, surround, etc.)
        ├── lsp/
        │   ├── completions.lua - Completion engine (nvim-cmp) and snippets
        │   ├── config.lua      - Global LSP configurations
        │   ├── init.lua        - Core LSP setup and initialization
        │   ├── keymaps.lua     - LSP-specific keybindings
        │   └── server_configs.lua - Language-specific server setups
        ├── startup.lua         - Dashboard/startup screen configuration
        ├── telescope.lua       - Telescope configuration
        └── ui.lua              - UI customization (statusline, colorscheme, etc.)
--]]

vim.g.mapleader = ","
vim.g.maplocalleader = "\\"

-- Load core configurations in this order
for _, mod in ipairs({ "options", "filetypes", "autocmds", "keymaps", "terminal" }) do
  require("core." .. mod)
end

-- Ask if plugins should be installed if not already
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
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
