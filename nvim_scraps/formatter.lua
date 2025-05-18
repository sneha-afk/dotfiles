-- Formatter configurations: default will fallback to the LSP
return {
  "stevearc/conform.nvim",
  enabled = false,
  keys = {
    {
      "<leader>cf",
      function() require("conform").format({ async = true }) end,
      desc = "[C]ode [F]ormat",
    },
  },
  ---@type conform.setupOpts
  opts = {
    formatters_by_ft = {
      lua = { "stylua", "lua_ls", stop_after_first = true },
    },
  },
}
