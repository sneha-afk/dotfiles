# nvim

**Minimum version required**: `v0.11.0`

Upon opening for the first time, you will be prompted on whether to install Lazy.nvim and the plugins
listed in `plugins/`.

## Cloning *just* this config
Powershell:
```powershell
git clone --depth 1 --filter=blob:none --sparse https://github.com/sneha-afk/dotfiles $env:TEMP\dotfiles; cd $env:TEMP\dotfiles; git sparse-checkout set dot-config/nvim; Copy-Item -Recurse dot-config/nvim $env:LOCALAPPDATA\nvim -Force
```

Bash:
```bash
git clone --depth 1 --filter=blob:none --sparse https://github.com/sneha-afk/dotfiles /tmp/dotfiles && cd /tmp/dotfiles && git sparse-checkout set dot-config/nvim && cp -r dot-config/nvim ~/.config/nvim
```

## Configuration

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
│       ├── formatter.lua
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
- Leader key set to `,` and localleader set to `\` in `.config/nvim/init.lua`

| File | Purpose |
|------|---------|
| `core/filetypes.lua` | Settings for groups of related filetypes |
| `core/keymaps.lua`   | Global keybindings and mappings |
| `core/options.lua`   | Basic Neovim settings (tabs, line numbers, etc.) |


#### LSP Configuration

| File | Purpose |
|------|---------|
| `plugins/lsp/init.lua` | Specs for LSP related plugins, where `vim.lsp.enable` is called |
| `plugins/lsp/config.lua`  | Configure shared settings for all LSPs, `LspAttach`, and `LspDetach` |
| `plugins/lsp/server_configs.lua` | Set up any extensions/overrides of LSP settings |
| `plugins/lsp/server_keymaps.lua` | Map server-specific commands, detected on `LspAttach` |

To add a new server:
1. If *globally* installed in the system, not through Mason, add the name to the list of `vim.lsp.enable` in `lsp/init.lua`
    - Mason will automatically enable servers installed through its interface
1. Optional: extend/override default `nvim-lspconfig` configurations with `vim.lsp.config` in `lsp/server_configs.lua`
1. Optional: define keymaps for when the LSP is active in `lsp/server_keymaps.lua`
