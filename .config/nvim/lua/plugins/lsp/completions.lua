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
    ["<Esc>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm(cmp_confirm),
    ["<Tab>"] = cmp.mapping(function(fallback) -- Either go to next item in menu, or next placeholder
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<C-n>"] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_next_item({ behavior = cmp.SelectBehavior.Insert })
      else
        cmp.complete()
      end
    end),
    ["<C-p>"] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_prev_item({ behavior = cmp.SelectBehavior.Insert })
      end
    end),
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp", priority = 1000 },                    -- LSP suggestions
    { name = "luasnip",  priority = 750 },                     -- Snippet suggestions
    { name = "buffer",   priority = 500 },                     -- Buffer words
    { name = "path",     priority = 250, keyword_length = 3 }, -- File system paths
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
    max_view_entries = 20,
  }
}
