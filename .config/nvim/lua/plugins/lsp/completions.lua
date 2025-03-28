-- .config/nvim/lua/plugins/lsp/completions.lua
-- Settings for completions and snippets

-- Snippet setup
local luasnip = require("luasnip")

luasnip.config.setup({
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
    vim.loop.cwd() .. "/.nvim/snippets"                  -- Project-specific snippets
  }
})

-- Completion setup
local cmp = require("cmp")
local cmp_confirm = { select = true, behavior = cmp.ConfirmBehavior.Replace }

return {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
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
    ["<CR>"] = cmp.mapping.confirm(cmp_confirm),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback() -- Fall back to default behavior when not doing completions
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  -- Keyword length: how many before querying that source
  sources = cmp.config.sources({
    { name = "path" },                         -- File system paths (files, directories)
    { name = "nvim_lsp", keyword_length = 1 }, -- LSP suggestions
    { name = "buffer",   keyword_length = 3 }, -- Buffer words
    { name = "luasnip",  keyword_length = 2 }  -- Snippet suggestions
  }),
  formatting = {
    fields = { "menu", "abbr", "kind" },
    format = function(entry, item)
      local menu_icon = {
        path = "🖫",
        nvim_lsp = "◎",
        buffer = "✦",
        luasnip = "☇",
      }
      item.menu = menu_icon[entry.source.name] or "?"
      return item
    end,
  },
  sorting = {
    priority_weight = 2.0,
    comparators = {
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,
      cmp.config.compare.recently_used,
      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
    }
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  experimental = {
    ghost_text = {
      hl_group = "Comment", -- Style for inline suggestions
    },
  },
  performance = {
    debounce = 60,
    throttle = 30,
    fetching_timeout = 200,
  }
}
