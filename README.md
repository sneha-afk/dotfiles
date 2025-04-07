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

New-Item -ItemType SymbolicLink `
  -Path "$HOME\_vimrc" `
  -Target "getthispathidk\dotfiles\.vimrc"
```

## Neovim
Upon opening with a new configuration, it will ask you whether plugins should be installed or not.

`neovim_reset` and `neovim_config_size` are present in [`.bashrc`](.bashrc).

### Configuration Structure

```
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
```

### Modifying
`.config/nvim/init.lua` contains the leader key mapping **(set to comma `,`)**

| File | Purpose |
|------|---------|
| `core/options.lua` | Basic Neovim settings (tabs, line numbers, etc.) |
| `core/keymaps.lua` | Global keybindings and mappings |

#### Plugin Configuration
| File | Purpose |
|------|---------|
| `plugins/helpers.lua` | Utility plugins |
| `plugins/ui.lua` | Visual appearance (theme, statusline, etc.) |
| `plugins/startup.lua` | Welcome screen |

#### LSP Configuration
For *every* server used, list in `server_configs.lua` with at least `name = {}` to use default configurations provided by `nvim-lspconfig`.

| File | Purpose |
|------|---------|
| `plugins/lsp/config.lua` | Common LSP configurations shared across all |
| `plugins/lsp/completions.lua` | Completion and snippet configurations |
| `plugins/lsp/keymaps.lua` | Keymaps for interacting with LSPs |
| `plugins/lsp/server_configs.lua` | Set up servers and optionally override settings |

