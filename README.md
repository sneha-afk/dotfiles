# dotfiles

## Setup
After cloning the repo, setting up symlinks in the home directory can be done for ease:

```bash
# Run from the repository root
ln -sf "$(pwd)/.config/nvim" "$HOME/.config/nvim"
ln -sf "$(pwd)/.vimrc" "$HOME/.vimrc"
ln -sf "$(pwd)/.bashrc" "$HOME/.bashrc"
```

And for Powershell:
```ps
New-Item -ItemType SymbolicLink `
-Path "getthispathidk\dotfiles\Microsoft.PowerShell_profile.ps1" `
-Target $PROFILE
```

## Neovim
Upon opening with a new configuration, it will ask you whether plugins should be installed or not.

`neovim_reset` and `neovim_config_size` are present in [`.bashrc`](.bashrc).

### Configuration Structure

```
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
```

### Modifying
`.config/nvim/init.lua` contains the leader key mapping **(set to comma `,`)**

| File | Purpose |
|------|---------|
| `lua/core/options.lua` | Basic Neovim settings (tabs, line numbers, etc.) |
| `lua/core/keymaps.lua` | Global keybindings and mappings |

#### Plugin Configuration
| File | Purpose |
|------|---------|
| `lua/plugins/editor.lua` | Text editing enhancements and utilities |
| `lua/plugins/ui.lua` | Visual appearance (theme, statusline, etc.) |
| `lua/plugins/startup.lua` | Welcome screen |

#### LSP Configuration
For *every* server used, list in `server_configs.lua` with at least `name = {}` to use default configurations provided by `nvim-lspconfig`.

| File | Purpose |
|------|---------|
| `lua/plugins/lsp/config.lua` | Common LSP configurations shared across all |
| `lua/plugins/lsp/completions.lua` | Completion and snippet configurations |
| `lua/plugins/lsp/keymaps.lua` | Keymaps for interacting with LSPs |
| `lua/plugins/lsp/server_configs.lua` | Set up servers and optionally override settings |

