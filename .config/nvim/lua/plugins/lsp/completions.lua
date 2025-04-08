-- .config/nvim/lua/plugins/lsp/completions.lua
-- Settings for completions and snippets

local ls = require("luasnip")

ls.config.setup({
  history = true,
  region_check_events = "InsertEnter",
  update_events = "TextChanged,TextChangedI",
  delete_check_events = "TextChanged",
})

-- Load snippets
require("luasnip.loaders.from_vscode").lazy_load({
  paths = {
    vim.fn.stdpath("data") .. "/lazy/friendly-snippets", -- Built-in vscode-style snippets
    vim.fn.stdpath("config") .. "/snippets",             -- Personal snippets in .config/nvim/snippets
    vim.uv.cwd() .. "/.nvim/snippets"                    -- Project-specific snippets
  }
})

-- Completion setup
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
    ["<C-Space>"] = cmp.mapping.complete(), -- Manual trigger
    ["<C-e>"] = cmp.mapping.abort(),        -- Close menu
    ["<Esc>"] = cmp.mapping.abort(),
    -- Select: true if select whatever is under cursor, false if need to interact with menu first
    ['<CR>'] = cmp.mapping.confirm({ select = false }),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fallback) -- Either go to next item in menu, or next placeholder
      if cmp.visible() then
        cmp.select_next_item()
      elseif ls.jumpable(1) then
        ls.jump(1)
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif ls.jumpable(-1) then
        ls.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
    ['<C-p>'] = cmp.mapping.select_prev_item(select_opts),
    ['<C-n>'] = cmp.mapping.select_next_item(select_opts),
    ['<C-j>'] = cmp.mapping.scroll_docs(-4),
    ['<C-k>'] = cmp.mapping.scroll_docs(4),
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
  performance = {
    max_view_entries = 15,
  }
}
