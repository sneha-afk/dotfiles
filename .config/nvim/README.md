# nvim

Upon opening for the first time, you will be prompted on whether to install Lazy.nvim and the plugins
listed in `plugins/`.

Helpers defined in [`.bashrc`](/.bashrc):
1. `nvim_size`: size of entire configuration + LSPs installed through Mason
2. `nvim_reset`: deletes setup (configuration files kept)
3. `nvim_dump_swap`: delete swap files

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

#### LSP Configuration
To set up a new LSP server:
1. List it in `server_configs.lua` with at least `name = {}` to use default configurations provided by `nvim-lspconfig`.
2. Add the filetype supported to the `lsp_languages` table at the top of `lsp/init.lua`

| File | Purpose |
|------|---------|
| `plugins/lsp/config.lua` | Common LSP configurations shared across all |
| `plugins/lsp/completions.lua` | Completion and snippet configurations |
| `plugins/lsp/keymaps.lua` | Keymaps for interacting with LSPs |
| `plugins/lsp/server_configs.lua` | Set up servers and optionally override settings |

