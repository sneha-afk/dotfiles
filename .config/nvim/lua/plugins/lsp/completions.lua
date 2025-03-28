-- .config/nvim/lua/plugins/lsp/completions.lua
-- Settings for completions and snippets

local cmp = require("cmp")
local luasnip = require("luasnip")

luasnip.config.setup({
  history = true,
  region_check_events = "InsertEnter",
  update_events = "TextChanged,TextChangedI",
})
require("luasnip.loaders.from_vscode").lazy_load()

return {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = {
    completeopt = "menu,menuone,noselect",
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-Space>"] = cmp.mapping.complete(),  -- Manual trigger
    ["<C-e>"] = cmp.mapping.abort(),         -- Close menu
    ["<CR>"] = cmp.mapping.confirm({         -- Confirm selection
      select = true,                         -- Auto-select if none chosen
      behavior = cmp.ConfirmBehavior.Replace -- Overwrite text on confirm
    }),
    ["<Tab>"] = cmp.mapping(function(fallback)
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
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" }, -- Language Server completions
    { name = "luasnip" },  -- Snippets
    { name = "buffer" },   -- Current buffer words
    { name = "path" },     -- Filesystem paths
  }),
  sorting = {
    comparators = {
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,
      cmp.config.compare.recently_used,
      cmp.config.compare.kind, -- Group by completion type
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
}
