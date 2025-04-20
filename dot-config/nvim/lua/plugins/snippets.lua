-- .config/nvim/lua/plugins/lsp/snippets.lua
-- Configures snippet engine, lazy-loaded by completions.lua

return {
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
        (vim.uv or vim.loop).cwd() .. "/.nvim/snippets"      -- Project-specific snippets
      }
    })
  end
}
