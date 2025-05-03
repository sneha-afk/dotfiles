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
      { "<leader>lm", "<cmd>Mason<cr>", desc = "Open [L]SP [M]anager" },
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
        opts = {
          automatic_installation = false,
        },
      },
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- Setup keymaps and autocommands, get back a vim.lsp.Config
      local global_configs = require("plugins.lsp.config")

      -- Shared configurations + capabilities
      vim.lsp.config("*", global_configs)

      -- Set up any overrides
      require("plugins.lsp.server_configs")

      -- Enable LSPs to attach when their respective filetypes are opened
      vim.lsp.enable({
        "lua_ls", "gopls", "clangd", "pyright",
      })

      vim.lsp.inlay_hint.enable()
    end
  },
}
