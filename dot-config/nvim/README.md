# nvim

**Minimum version required**: `v0.11.0`

Upon opening for the first time, you will be prompted on whether to install `lazy.nvim` as the package manager being used
and the plugins listed in `plugins/`.

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
├── README.md
├── init.lua
├── lazy-lock.json
├── lsp
│   └── (server-specific configs)
├── lua
│   ├── core
│   │   ├── commands.lua
│   │   ├── filetypes.lua
│   │   ├── highlights.lua
│   │   ├── keymaps.lua
│   │   ├── lazy.lua
│   │   ├── neovide.lua
│   │   ├── options.lua
│   │   └── terminal.lua
│   ├── plugins
│   │   ├── colorscheme.lua
│   │   ├── completions.lua
│   │   ├── extras.lua
│   │   ├── formatter.lua
│   │   ├── helpers.lua
│   │   ├── lsp
│   │   │   ├── init.lua
│   │   │   └── lsp_keymaps.lua
│   │   ├── snacks.lua
│   │   ├── statusline.lua
│   │   ├── treesitter.lua
│   │   ├── ui.lua
│   │   ├── vimtex.lua
│   │   └── which_key.lua
│   └── utils
│       ├── buffers_and_windows.lua
│       ├── fileops.lua
│       └── ui.lua
├── snippets
│   └── (snippets per language)
└── spell
```

### Modifying
Leader key set to `,` and localleader set to `\` in `.config/nvim/init.lua`

| File | Purpose |
|------|---------|
| `core/filetypes.lua` | Settings for groups of related filetypes |
| `core/keymaps.lua`   | Global keybindings and mappings |
| `core/options.lua`   | Basic Neovim settings (tabs, line numbers, etc.) |

#### LSP Configuration

| File | Purpose |
|------|---------|
| `plugins/lsp/init.lua` | Specs for LSP related plugins, where `vim.lsp.enable` is called |
| `plugins/lsp/lsp_keymaps.lua` | Map server-specific commands, detected on `LspAttach` |
| `after/lsp/server_name.lua` | Server-specific configuration overrides (0.11+) |

To add a new server:
1. If *globally* installed in the system (not through Mason), add the name to the list of `vim.lsp.enable` in `plugins/lsp/init.lua`
    - Mason will automatically enable servers installed through its interface (recommended!)
2. Optional: override default `nvim-lspconfig` configurations by creating `.config/nvim/after/lsp/server_name.lua` (preferred) or using `vim.lsp.config`
    - Using a dedicated file in the `after/lsp/` directory prevents timing issues with lazy loading configurations (preferred in 0.11+)
    - `lsp/` vs. `after/lsp` is to ensure overrides of `nvim-lspconfig` are *always* sourced at the end (see [related PR](https://github.com/neovim/nvim-lspconfig/pull/4212))
3. Optional: define keymaps for when the LSP is active in `plugins/lsp/lsp_keymaps.lua`
