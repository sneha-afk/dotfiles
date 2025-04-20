-- .config/nvim/lua/plugins/lsp/init.lua

return {
  -- Mason configuration (LSP installer)
  -- Installed to "$HOME/.local/share/nvim/mason/bin"
  {
    "williamboman/mason.nvim",
    lazy = true,
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
    build = ":MasonUpdate",
    keys = {
      { "<leader>lm", "<cmd>Mason<cr>", desc = "Open Mason LSP manager" },
    },
    opts = {
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },

  -- LSP configurations: both externally installed and from Mason
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile", "VeryLazy" },
    cmd = { "LspInfo", "LspRestart" },
    dependencies = {
      {
        -- Mason-LSPConfig bridge
        "williamboman/mason-lspconfig.nvim",
        cmd = { "LspInstall", "LspUninstall" },
        dependencies = { "williamboman/mason.nvim" },
        opts = {},
      },
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local shared_configs = require("plugins.lsp.config")
      local server_overrides = require("plugins.lsp.server_configs")

      if vim.fn.has("nvim-0.11") == 1 then
        vim.lsp.config("*", shared_configs)
        for server_name, overrides in pairs(server_overrides) do
          vim.lsp.config(server_name, overrides)
        end
        vim.lsp.enable(vim.tbl_keys(server_overrides))
      else
        for server_name, overrides in pairs(server_overrides) do
          lspconfig[server_name].setup(vim.tbl_deep_extend("force", shared_configs, overrides))
        end
      end
    end
  },
}
