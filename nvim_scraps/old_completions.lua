-- .config/nvim/lua/plugins/completions-nvim-cmp.lua
-- Thanks to https://vonheikemen.github.io/devlog/tools/setup-nvim-lspconfig-plus-nvim-cmp/
-- Backing up previous completion setup

return {
  "hrsh7th/nvim-cmp",
  enabled = false,
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",       -- LSP completions
    {
      "saadparwaiz1/cmp_luasnip", -- Snippet completions
      dependencies = {
        {
          "L3MON4D3/LuaSnip",
          lazy = true,
          dependencies = {
            "rafamadriz/friendly-snippets",
          },
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
    },
    "hrsh7th/cmp-buffer", -- Buffer words
    "hrsh7th/cmp-path",   -- File paths
    "f3fora/cmp-spell",
  },
  opts = function()
    local ls = require("luasnip")
    local cmp = require("cmp")

    local select_opts = { behavior = cmp.SelectBehavior.Select }

    return {
      snippet = {
        expand = function(args) ls.lsp_expand(args.body) end,
      },
      completion = {
        completeopt = "menu,menuone,noselect",
        keyword_length = 1,
        autocomplete = {
          cmp.TriggerEvent.TextChanged,
          cmp.TriggerEvent.InsertEnter,
        },
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(),  -- Manual trigger
        ["<C-e>"] = cmp.mapping.abort(),         -- Close menu
        ["<C-j>"] = cmp.mapping.scroll_docs(-4), -- Scroll down
        ["<C-k>"] = cmp.mapping.scroll_docs(4),  -- Scroll up

        -- Select: true if select whatever is under cursor, false if need to interact with menu first
        -- Replace: replace entire word under cursor (important to not have butchered characters)
        ["<CR>"] = cmp.mapping.confirm({ select = false, behavior = cmp.ConfirmBehavior.Replace }),
        ["<C-y>"] = cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Replace }),

        -- Tab/S-Tab will cycle menu items or jump in a (local) snippet
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item(select_opts)
          elseif ls.expand_or_locally_jumpable() then
            ls.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item(select_opts)
          elseif ls.locally_jumpable(-1) then
            ls.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),

        -- <C-p> and <C-n> is also used for the above operations
        ["<C-p>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item(select_opts)
          elseif ls.jumpable(-1) then
            ls.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<C-n>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item(select_opts)
          elseif ls.jumpable(1) then
            ls.jump(1)
          else
            fallback()
          end
        end, { "i", "s" }),

        -- More snippet jump shortcuts
        ["<C-l>"] = cmp.mapping(function(fallback)
          if ls.expand_or_locally_jumpable() then
            ls.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<C-h>"] = cmp.mapping(function(fallback)
          if ls.jumpable(-1) then
            ls.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp", priority = 1000 },                  -- LSP suggestions
        { name = "luasnip",  priority = 900 },                   -- Snippet suggestions
        { name = "path",     priority = 500 },                   -- File system paths
        { name = "buffer",   priority = 250, keyword_length = 3 }, -- Buffer words
        { name = "spell",    priority = 100, keyword_length = 2 },
      }),
      formatting = {
        fields = { "menu", "abbr", "kind" },
        format = function(entry, item)
          local menu_icon = {
            path = "🖫",
            nvim_lsp = "✦",
            buffer = "⚇",
            luasnip = "⌥",
            spell = "⌯",
          }
          item.menu = menu_icon[entry.source.name] or "?"
          return item
        end,
      },
      sorting = {
        priority_weight = 2.0,
        comparators = {
          cmp.config.compare.score,         -- Respect LSP relevance
          cmp.config.compare.offset,        -- Prefer nearby symbols
          cmp.config.compare.exact,         -- Exact matches
          cmp.config.compare.recently_used, -- Boost frequently used items
          cmp.config.compare.kind,          -- Group by type (e.g., functions before variables)
          cmp.config.compare.sort_text,     -- Secondary LSP hints
          cmp.config.compare.length,        -- Prefer shorter names
          cmp.config.compare.order,         -- Alphabetical fallback
        },
      },
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      experimental = {
        ghost_text = true,
      },
      performance = {
        debounce = 30,                 -- How long to wait after typing stops
        throttle = 40,                 -- How often to update while typing
        fetching_timeout = 500,        -- Timeout for slower sources
        filtering_context_budget = 60, -- Time allowed for cmp before control goes back to nvim
        confirm_resolve_timeout = 100, -- Time for resolving item before completion
        async_budget = 15,             -- Time async func can run during one step of event loop
        max_view_entries = 15,         -- How many entries to disiplay in cmp menu
      },
    }
  end,
  config = function(_, opts)
    local cmp = require("cmp")
    cmp.setup(opts)

    -- Color of the source icon
    vim.api.nvim_set_hl(0, "CmpItemMenu", { link = "Constant" })

    local toggle_ghost_text = function()
      local cmp_config = cmp.get_config()
      cmp_config.experimental.ghost_text = not cmp_config.experimental.ghost_text
      cmp.setup(cmp_config)
      vim.notify("Ghost text: " .. (cmp_config.experimental.ghost_text and "enabled" or "disabled"), vim.log.levels.INFO)
    end
    vim.keymap.set("n", "<leader>ug", toggle_ghost_text, { desc = "[U]I: toggle [G]host text" })
  end,
}
