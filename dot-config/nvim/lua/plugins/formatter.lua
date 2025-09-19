-- .config/nvim/lua/plugins/formatter.lua
-- Formatter must be in PATH, best to install from Mason

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
    format_on_save = function(bufnr)
      -- Disable with a global or buffer-local variable
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
        return
      end

      -- Disable autoformat for certain filetypes
      local ignore_ft = {
        markdown = true,
        text = true,
      }
      if ignore_ft[vim.bo[bufnr].filetype] then return end

      return { timeout_ms = 500, lsp_format = "fallback" }
    end,
  },
  config = function(_, opts)
    for _, ft in ipairs({
      "angular", "css", "flow", "graphql", "html", "htmldjango", "javascript", "javascriptreact", "jsx",
      "json", "jsonc", "less", "markdown", "scss", "typescript", "typescriptreact", "tsx", "vue", "yaml",
    }) do
      opts.formatters_by_ft[ft] = { "prettierd", "prettier", stop_after_first = true }
    end

    local conform = require("conform")
    conform.setup(opts)

    --- Redefine vim.lsp.buf.format so other settings don't need to change
    ---@diagnostic disable-next-line: duplicate-set-field
    vim.lsp.buf.format = conform.format

    -- https://github.com/stevearc/conform.nvim/blob/master/doc/recipes.md#command-to-toggle-format-on-save
    vim.api.nvim_create_user_command("FormatDisable", function(args)
      if args.bang then
        -- FormatDisable! will disable formatting just for this buffer
        vim.b.disable_autoformat = true
      else
        vim.g.disable_autoformat = true
      end
    end, {
      desc = "Disable autoformat-on-save",
      bang = true,
    })
    vim.api.nvim_create_user_command("FormatEnable", function()
      vim.b.disable_autoformat = false
      vim.g.disable_autoformat = false
    end, {
      desc = "Re-enable autoformat-on-save",
    })
  end,
}
