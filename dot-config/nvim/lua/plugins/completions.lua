-- .config/nvim/lua/plugins/completions.lua

return {
  "saghen/blink.cmp",
  enabled = true,
  event = "InsertEnter",
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  keys = {
    {
      "<leader>ct",
      function()
        -- Could be nil before explicitly set to a boolean
        if vim.b.completion == nil then vim.b.completion = true end
        vim.b.completion = not vim.b.completion
        vim.notify("Completion toggled to: " .. (vim.b.completion and "enabled" or "disabled"), vim.log.levels.INFO)
      end,
      desc = "[C]ompletion: [t]oggle",
    },
  },
  -- Use version to download pre-built
  version = "1.*",
  -- build = "cargo build --release",
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
      ["<C-f>"] = { "show", "show_documentation", "hide_documentation" }, -- Duplicate C-space in case of terminal issues
      ["<Enter>"] = { "accept", "fallback" },                             -- Both <C-y> and Enter will accept
      ["<C-j>"] = { "scroll_documentation_down", "fallback" },
      ["<C-k>"] = { "scroll_documentation_up", "fallback" },
      ["<C-h>"] = { "snippet_backward", "fallback" },
      ["<C-l>"] = { "snippet_forward", "fallback" },
    },
    sources = {
      default = { "lsp", "snippets", "path", "buffer" },
      per_filetype = {
        tex = { "snippets", "latex", "omni", "buffer" },
        lua = { inherit_defaults = true, "lazydev" },
      },
      providers = {
        buffer = { score_offset = -5 },
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          score_offset = 100,
        },
        latex = {
          name = "Latex",
          module = "blink-cmp-latex",
          opts = { -- True: insert the LaTeX command instead of the symbol
            insert_command = true,
          },
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
        min_width = 25,
        max_height = 10,
        border = "rounded",
        draw = {
          components = {
            kind_icon = {
              text = function(ctx)
                local menu_icon = {
                  path = "🖫",
                  lsp = "✦",
                  latex = "✒",
                  buffer = "⚇",
                  omni = "⎉",
                  snippets = "⌥",
                  cmdline = "λ",
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
    fuzzy = {
      sorts = {
        -- "exact",
        "score",
        "sort_text",
      },
    },
  },
  opts_extend = { "sources.default" },
}
