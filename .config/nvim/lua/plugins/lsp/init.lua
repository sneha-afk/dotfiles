-- .config/nvim/lua/plugins/lsp/init.lua
-- Initialization of the LSP configuration with Mason, completes, and neovim-lspconfig

local default_servers = { "lua_ls" }

return {
  -- Mason configuration (LSP installer)
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
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

  -- Mason-LSPConfig bridge
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = default_servers or {},
      automatic_installation = true,
    },
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",     -- LSP completions
      "L3MON4D3/LuaSnip",         -- Snippet engine
      "rafamadriz/friendly-snippets",
      "saadparwaiz1/cmp_luasnip", -- Snippet completions
      "hrsh7th/cmp-buffer",       -- Buffer words
      "hrsh7th/cmp-path",         -- File paths
    },
    opts = function()
      return require("plugins.lsp.completions")
    end,
  },

  -- LSP configurations
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local shared_configs = require("plugins.lsp.config")
      local server_overrides = require("plugins.lsp.server_configs")

      -- Setup diagnostics
      vim.diagnostic.config({
        update_in_insert = true,
        virtual_text = { prefix = "●" },
        severity_sort = true,
        float = { border = "rounded" },
      })

      -- Setup handlers' UI
      require('plugins.lsp.handlers').setup()

      -- Extend from defaults in lspconfig
      for server_name, config_overrides in pairs(server_overrides) do
        require("lspconfig")[server_name].setup(
          vim.tbl_deep_extend("force",
            shared_configs.default_config, -- Shared configuration
            config_overrides               -- Server-specific overrides
          )
        )
      end
    end
  },
}
