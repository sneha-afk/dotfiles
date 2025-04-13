-- .config/nvim/lua/plugins/lsp/init.lua
-- Initialization of the LSP configuration with Mason, completes, and nvim-lspconfig

-- What to install through Mason
local servers_to_install = { "lua_ls", "bashls" }

-- Language files that LSPs should be enabled for (reduces startup for non-LSP configured files)
local lsp_languages = { "lua", "sh", "bash", "zsh", "c", "cpp", "h", "hpp", "python", "go", }

return {
  -- Mason configuration (LSP installer)
  -- Installed to "$HOME/.local/share/nvim/mason/bin"
  {
    "williamboman/mason.nvim",
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

  -- Mason-LSPConfig bridge
  {
    "williamboman/mason-lspconfig.nvim",
    ft = lsp_languages,
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      -- Servers to be installed through Mason, see top of file
      ensure_installed = servers_to_install or {},

      -- Will not automatically install configured servers to allow using global installs
      automatic_installation = false,
    },
  },

  -- LSP configurations: both externally installed and from Mason
  {
    "neovim/nvim-lspconfig",
    ft = lsp_languages,
    cmd = { "LspInfo" },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local shared_configs = require("plugins.lsp.config")
      local server_overrides = require("plugins.lsp.server_configs")

      -- Pass overrides from default configurations
      for server_name, overrides in pairs(server_overrides) do
        lspconfig[server_name].setup(
          vim.tbl_deep_extend("force",
            shared_configs, -- Shared configuration
            overrides       -- Server-specific overrides
          )
        )
      end
    end
  },
}
