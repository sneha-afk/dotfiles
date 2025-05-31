-- .config/nvim/lua/plugins/lsp/init.lua

return {
  -- Lazy-loads plugin completions
  {
    "folke/lazydev.nvim",
    ft = "lua",
    cmd = "LazyDev",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },

  -- Mason configuration (LSP installer)
  -- Installed to "$HOME/.local/share/nvim/mason/bin"
  {
    "mason-org/mason.nvim",
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
    keys = {
      { "<leader>li", "<cmd>LspInfo<cr>", desc = "[L]SP: [I]nfo" },
      {
        "<leader>lr",
        function()
          local clients = vim.lsp.get_clients({ bufnr = 0 })
          for _, client in pairs(clients) do
            if client.name then
              vim.cmd("LspRestart " .. client.name)
              vim.notify(("Restarted LSP " .. client.name), vim.log.levels.INFO)
            end
          end
        end,
        desc = "[L]SP: [R]estart",
      },
    },
    dependencies = {
      {
        -- Mason-LSPConfig bridge
        "mason-org/mason-lspconfig.nvim",
        cmd = { "LspInstall", "LspUninstall" },
        dependencies = { "mason-org/mason.nvim" },
        opts = {
          -- Calls vim.lsp.enable for every installed LSP
          automatic_enable = true,
          ensure_installed = {},
        },
      },
    },
    config = function()
      -- Setup keymaps and autocommands, get back a vim.lsp.Config
      local global_configs = require("plugins.lsp.config")

      -- Shared configurations + capabilities
      vim.lsp.config("*", global_configs)

      -- Use vim.lsp.config for further configuration
      require("plugins.lsp.server_configs")

      -- Enable LSPs to attach when their respective filetypes are opened
      vim.lsp.enable({
        "lua_ls",
        "gopls",
        "clangd",
        "pyright",
      })

      vim.lsp.inlay_hint.enable()
    end,
  },
}
