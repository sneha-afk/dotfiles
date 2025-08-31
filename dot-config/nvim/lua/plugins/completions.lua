-- .config/nvim/lua/plugins/completions.lua

return {
  "saghen/blink.cmp",
  enabled = true,
  event = "InsertEnter",
  dependencies = {
    "rafamadriz/friendly-snippets",
    {
      "L3MON4D3/LuaSnip",
      version = "v2.*",
      build = "make install_jsregexp",
      opts = {
        history = true,
        region_check_events = "InsertEnter",
        update_events = "TextChanged,TextChangedI",
        delete_check_events = "TextChanged",
      },
      config = function(_, opts)
        require("luasnip").config.setup(opts)

        require("luasnip.loaders.from_vscode").lazy_load({
          paths = {
            vim.fn.stdpath("data") .. "/lazy/friendly-snippets", -- Built-in vscode-style snippets
            vim.fn.stdpath("config") .. "/snippets",             -- Personal snippets in .config/nvim/snippets
            vim.uv.cwd() .. "/.nvim/snippets",                   -- Project-specific snippets
          },
        })

        vim.api.nvim_create_user_command("EditSnippets", function()
          require("luasnip.loaders").edit_snippet_files({
            format = function(file, source_name)
              local path_replacements = {
                ["/.local/share/nvim/lazy/friendly%-snippets"] = "FriendlySnippets",
                ["/.config/nvim/snippets"] = "Personal",
                ["/dotfiles/dot%-config/nvim/snippets"] = "Personal",
                [vim.uv.cwd() .. "/.nvim/snippets"] = "Project",
                ["/.local/share/nvim/lazy/LuaSnip"] = "LuaSnip",
              }

              for pattern, label in pairs(path_replacements) do
                if file:find(pattern) then
                  local filename = file:match(".*/(.*)$") or file
                  return string.format("%s : %s", label, filename)
                end
              end
              return file
            end,
          })
        end, { desc = "Open snippet files for editing" })
      end,
    },
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
      ["<Enter>"] = { "accept", "fallback" }, -- Both <C-y> and Enter will accept
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
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          score_offset = 100,
        },
        latex = {
          name = "Latex",
          module = "blink-cmp-latex",
          opts = {
            -- set to true to insert the latex command instead of the symbol
            insert_command = true,
          },
        },
        snippets = {
          opts = {
            -- Selectively disable snippets by returning false
            -- filter_snippets = function(ft, file)
            --   -- 2025-08-31: Excessive lag on Windows only on my own snippets, when using vim.snippet
            --   return not (vim.g.is_windows and file:find("latex.json"))
            -- end,
          },
        },
      },
    },
    snippets = { preset = "luasnip" },
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
