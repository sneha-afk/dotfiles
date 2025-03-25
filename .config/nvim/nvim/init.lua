-- Neovim Configuration
-- File location: ~/.config/nvim/init.lua (Linux/macOS)
--                ~/AppData/Local/nvim/init.lua (Windows)

-- Configuration structure:
-- ~/.config/nvim/
-- ├── init.lua             # Main entry point
-- ├── lua/
-- │   ├── core/            # Core Neovim settings
-- │   │   ├── options.lua  # Basic editor settings
-- │   │   ├── keymaps.lua  # Key mappings
-- │   │   ├── autocmds.lua # Autocommands
-- │   │   └── terminal.lua # Terminal settings
-- │   └── plugins/         # Plugin configurations
-- │       ├── init.lua     # Plugin manager setup
-- │       ├── ui.lua       # UI plugins (colorscheme, statusline)
-- │       ├── editor.lua   # Editing plugins (autopairs, comments)
-- │       └── tools.lua    # Tools (file tree, etc.)
-- └── after/               # (Optional) Overrides

-- Load core configurations
require('core.options')
require('core.keymaps')
require('core.autocmds')
require('core.terminal')

-- To have a plain installation, leave out the plugins/ folder
-- Initialize plugin manager and load plugins
require('plugins.init')
