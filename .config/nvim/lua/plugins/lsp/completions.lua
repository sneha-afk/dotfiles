-- .config/nvim/lua/plugins/lsp/completions.lua
-- Settings for completions and snippets

local cmp = require("cmp")
local luasnip = require("luasnip")

luasnip.config.setup({
  history = true,
  region_check_events = 'InsertEnter',
  update_events = 'TextChanged,TextChangedI',
  delete_check_events = 'TextChanged',
})

-- Load snippets
require('luasnip.loaders.from_vscode').lazy_load({
  paths = {
    -- 1. Load built-in vscode-style snippets
    vim.fn.stdpath("data") .. "/lazy/friendly-snippets",

    -- 2. Load personal nippets
    vim.fn.stdpath('config') .. '/snippets',

    -- 3. Load project-specific snippets
    vim.loop.cwd() .. '/.nvim/snippets'
  }
})

local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_confirm = {
  select = true,
  behavior = cmp.ConfirmBehavior.Replace
}

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
    ["<C-Space>"] = cmp.mapping.complete(), -- Manual trigger
    ["<C-e>"] = cmp.mapping.abort(),        -- Close menu
    ["<CR>"] = cmp.mapping.confirm(cmp_confirm),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback() -- Fall back to default behavior when not doing completions
      end
    end, { 'i', 's' }),

    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp', priority = 1000 },
    { name = 'luasnip',  priority = 900 },
    { name = 'buffer',   priority = 500, keyword_length = 3 },
    { name = 'path',     priority = 250 },
  }),
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
