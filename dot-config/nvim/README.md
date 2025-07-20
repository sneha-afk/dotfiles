# nvim

<a href="https://dotfyle.com/sneha-afk/dotfiles-dot-config-nvim"><img src="https://dotfyle.com/sneha-afk/dotfiles-dot-config-nvim/badges/plugins?style=flat-square" /></a>
<a href="https://dotfyle.com/sneha-afk/dotfiles-dot-config-nvim"><img src="https://dotfyle.com/sneha-afk/dotfiles-dot-config-nvim/badges/leaderkey?style=flat-square" /></a>
<a href="https://dotfyle.com/sneha-afk/dotfiles-dot-config-nvim"><img src="https://dotfyle.com/sneha-afk/dotfiles-dot-config-nvim/badges/plugin-manager?style=flat-square" /></a>

> Badges from [Dotfyle](https://dotfyle.com)

Upon opening for the first time, you will be prompted on whether to install Lazy.nvim and the plugins
listed in `plugins/`.

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
│       ├── extras.lua
│       ├── hardtime.lua
│       ├── helpers.lua
│       ├── live_preview.lua
│       ├── lsp/
│       │   ├── config.lua
│       │   ├── init.lua
│       │   ├── server_configs.lua
│       │   └── server_keymaps.lua
│       ├── oil.lua
│       ├── sessions.lua
│       ├── snacks.lua
│       ├── startup.lua
│       ├── statusline.lua
│       ├── telescope.lua
│       ├── treesitter.lua
│       ├── ui.lua
│       ├── vimtex.lua
│       └── which_key.lua
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
