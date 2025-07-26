-- .config/nvim/lua/plugins/formatter.lua

return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    { "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, desc = "[C]ode [F]ormat" },
  },
  ---@module "conform"
  ---@type conform.setupOpts
  opts = {
    formatters_by_ft = {
      sh = { "shfmt" },
    },
    formatters = {
      shfmt = {
        prepend_args = { "-i", "4", "-ci", "-sr" },
      },
    },
    default_format_opts = {
      lsp_format = "fallback",
    },
  },
  config = function(_, opts)
    for _, ft in ipairs({
      "angular", "css", "flow", "graphql", "html", "javascript", "javascriptreact", "jsx",
      "json", "less", "markdown", "scss", "typescript", "typescriptreact", "tsx", "vue", "yaml",
    }) do
      opts.formatters_by_ft[ft] = { "prettierd", "prettier", stop_after_first = true }
    end

    local conform = require("conform")
    conform.setup(opts)

    --- Redefine vim.lsp.buf.format so other settings don't need to change
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.lsp.buf.format = conform.format
  end,
}
