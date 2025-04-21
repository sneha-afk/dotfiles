# nvim

Upon opening for the first time, you will be prompted on whether to install Lazy.nvim and the plugins
listed in `plugins/`.

Helpers defined in [`.bashrc`](/dot-bash/.bashrc):
1. `nvim_size`: size of entire configuration + LSPs installed through Mason
2. `nvim_reset`: deletes setup (configuration files kept)
3. `nvim_dump_swap`: delete swap files

### Configuration Structure

```
~/.config/nvim/
├── init.lua
├── lua/
│   ├── core/
│   │   ├── autocmds.lua
│   │   ├── filetypes.lua
│   │   ├── keymaps.lua
│   │   ├── lazy.lua
│   │   ├── options.lua
│   │   └── terminal.lua
│   └── plugins/
│       ├── colorscheme.lua
│       ├── completions.lua
│       ├── helpers.lua
│       ├── lsp/
│       │   ├── config.lua
│       │   ├── init.lua
│       │   ├── keymaps.lua
│       │   └── server_configs.lua
│       ├── snippets.lua
│       ├── startup.lua
│       ├── statusline.lua
│       ├── telescope.lua
│       ├── treesitter.lua
│       └── ui.lua
└── snippets/
```

### Modifying
`.config/nvim/init.lua` contains the leader key mapping **(set to comma `,`)**

| File | Purpose |
|------|---------|
| `core/options.lua` | Basic Neovim settings (tabs, line numbers, etc.) |
| `core/keymaps.lua` | Global keybindings and mappings |

#### LSP Configuration
To set up a new LSP server, list it in `server_configs.lua` with at least `name = {}` to use default configurations provided by `nvim-lspconfig`.

| File | Purpose |
|------|---------|
| `plugins/lsp/config.lua` | Common LSP configurations shared across all |
| `plugins/lsp/keymaps.lua` | Keymaps for interacting with LSPs |
| `plugins/lsp/server_configs.lua` | Set up servers and optionally override settings |
| `plugins/lsp/server_keymaps.lua` | Map server-specific commands, detected on `LspAttach` |

