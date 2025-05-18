-- .config/nvim/lua/plugins/completions.lua
-- Thanks to https://vonheikemen.github.io/devlog/tools/setup-nvim-lspconfig-plus-nvim-cmp/

return {
  "saghen/blink.cmp",
  enabled = true,
  event = "InsertEnter",
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  version = "1.*",
  ---@module "blink.cmp"
  ---@type blink.cmp.Config
  opts = {
    -- From the docs:
    -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
    -- 'super-tab' for mappings similar to vscode (tab to accept)
    -- 'enter' for enter to accept
    -- 'none' for no mappings
    --
    -- All presets:
    -- C-space: Open menu or open docs if already open
    -- C-n/C-p or Up/Down: Select next/previous item
    -- C-e: Hide menu
    -- C-k: Toggle signature help (if signature.enabled = true)
    keymap = {
      preset = "default",
      ["<Enter>"] = { "accept", "fallback" }, -- Both <C-y> and Enter will accept
      ["<C-j>"] = { "scroll_documentation_down", "fallback" },
      ["<C-k>"] = { "scroll_documentation_up", "fallback" },
      ["<C-h>"] = { "snippet_backward", "fallback" },
      ["<C-l>"] = { "snippet_forward", "fallback" },
    },
    sources = {
      default = { "lazydev", "lsp", "snippets", "path", "buffer" },
      providers = {
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          score_offset = 100,
        },
      },
    },
    signature = {
      enabled = true,
      window = {
        border = "rounded",
      },
    },
    completion = {
      documentation = {
        auto_show = true,
        window = {
          border = "rounded",
        },
      },
      ghost_text = {
        enabled = true,
        show_with_menu = false,
      },
      menu = {
        min_width = 20,
        max_height = 10,
        border = "rounded",
        draw = {
          components = {
            kind_icon = {
              text = function(ctx)
                local menu_icon = {
                  path = "🖫",
                  lsp = "✦",
                  buffer = "⚇",
                  snippets = "⌥",
                  cmdline = "⨠",
                  spell = "⌯",
                  lazydev = "💤",
                }
                return menu_icon[ctx.source_id] or "?"
              end,
              highlight = "Constant",
            },
          },
          columns = {
            { "kind_icon", "label", "label_description", gap = 1 },
            { "kind" },
          },
        },
      },
    },
  },
  opts_extend = { "sources.default" },
}
