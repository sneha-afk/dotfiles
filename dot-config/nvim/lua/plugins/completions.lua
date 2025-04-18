-- .config/nvim/lua/plugins/completions.lua

return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",       -- LSP completions
    {
      "saadparwaiz1/cmp_luasnip", -- Snippet completions
      dependencies = { "L3MON4D3/LuaSnip" },
    },
    "hrsh7th/cmp-buffer", -- Buffer words
    "hrsh7th/cmp-path",   -- File paths
  },
  opts = function()
    local ls = require("luasnip")
    local cmp = require("cmp")

    local select_opts = { behavior = cmp.SelectBehavior.Select }

    return {
      snippet = {
        expand = function(args)
          ls.lsp_expand(args.body)
        end,
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
        ['<C-j>'] = cmp.mapping.scroll_docs(-4), -- Scroll down
        ['<C-k>'] = cmp.mapping.scroll_docs(4),  -- Scroll up

        -- Select: true if select whatever is under cursor, false if need to interact with menu first
        ['<CR>'] = cmp.mapping.confirm({ select = false }),
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),

        -- Tab and S-Tab only apply to a completion menu
        ["<Tab>"] = cmp.mapping.select_next_item(select_opts),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(select_opts),

        -- <C-p> and <C-n> is also used to jump snippet placeholders
        ['<C-p>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item(select_opts)
          elseif ls.jumpable(-1) then
            ls.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
        ['<C-n>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item(select_opts)
          elseif ls.jumpable(1) then
            ls.jump(1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp", priority = 1000 },                    -- LSP suggestions
        { name = "luasnip",  priority = 900, keyword_length = 2 }, -- Snippet suggestions
        { name = "buffer",   priority = 500, keyword_length = 4 }, -- Buffer words
        { name = "path",     priority = 250, keyword_length = 4 }, -- File system paths
        { name = "emoji",    priority = 150 },
        { name = "spell",    priority = 100 },
      }),
      formatting = {
        fields = { "menu", "abbr", "kind" },
        format = function(entry, item)
          local menu_icon = {
            path = "🖫",
            nvim_lsp = "✦",
            buffer = "⚇",
            luasnip = "☇",
          }
          item.menu = menu_icon[entry.source.name] or "?"
          return item
        end,
      },
      sorting = {
        priority_weight = 2.0,
        comparators = {
          cmp.config.compare.offset,        -- Prefer nearby symbols
          cmp.config.compare.exact,         -- Exact matches
          cmp.config.compare.score,         -- Respect LSP relevance
          cmp.config.compare.recently_used, -- Boost frequently used items
          cmp.config.compare.kind,          -- Group by type (e.g., functions before variables)
          cmp.config.compare.sort_text,     -- Secondary LSP hints
          cmp.config.compare.length,        -- Prefer shorter names
          cmp.config.compare.order,         -- Alphabetical fallback
        }
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
        max_view_entries = 20,         -- How many entries to disiplay in cmp menu
      }
    }
  end,
  config = function(_, opts)
    local cmp = require("cmp")
    cmp.setup(opts)

    local toggle_ghost_text = function()
      local cmp_config = cmp.get_config()
      cmp_config.experimental.ghost_text = not cmp_config.experimental.ghost_text
      cmp.setup(cmp_config)
      vim.notify(
        "Ghost text: " .. (cmp_config.experimental.ghost_text and "enabled" or "disabled"),
        vim.log.levels.INFO
      )
    end
    vim.keymap.set("n", "<leader>ug", toggle_ghost_text, { desc = '[U]I: toggle [G]host text' })
  end
}
