# nvim

Upon opening for the first time, you will be prompted on whether to install Lazy.nvim and the plugins
listed in `plugins/`.

Helpers defined in [`.bashrc`](/dot-bash/.bashrc):
1. `nvim_size`: size of entire configuration + LSPs installed through Mason
2. `nvim_reset`: deletes setup (configuration files kept)
3. `nvim_dump_swap`: delete swap files
4. `nvim_goto_config`: navigates to base of config

### Configuration

Minimum version required: v0.11.0

```
~/.config/nvim/
├── init.lua
├── lua/
│   ├── core/
│   │   ├── commands.lua
│   │   ├── filetypes.lua
│   │   ├── keymaps.lua
│   │   ├── lazy.lua
│   │   ├── options.lua
│   │   ├── terminal.lua
│   │   └── utils.lua
│   └── plugins/
│       ├── colorscheme.lua
│       ├── completions.lua
│       ├── helpers.lua
│       ├── lsp/
│       │   ├── config.lua
│       │   ├── init.lua
│       │   ├── server_keymaps.lua
│       │   └── server_configs.lua
│       ├── sessions.lua
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
| `core/filetypes.lua` | Settings for groups of related filetypes |
| `core/keymaps.lua`   | Global keybindings and mappings |
| `core/options.lua`   | Basic Neovim settings (tabs, line numbers, etc.) |


#### LSP Configuration
To enable a new LSP server to be used with default `nvim-lspconfig` configurations, add it to the table
passed into `vim.lsp.enable` in `lsp/init.lua`.

To extend/override from the default settings, use `vim.lsp.config` within `lsp/server_configs.lua`.

| File | Purpose |
|------|---------|
| `plugins/lsp/config.lua`  | Configure shared settings for all LSPs, `LspAttach`, and `LspDetach` |
| `plugins/lsp/server_configs.lua` | Set up any extensions/overrides of LSP settings |
| `plugins/lsp/server_keymaps.lua` | Map server-specific commands, detected on `LspAttach` |

