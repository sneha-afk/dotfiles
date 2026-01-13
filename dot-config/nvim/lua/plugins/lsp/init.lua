-- .config/nvim/lua/lsp/init.lua

local lsp_utils = require("utils.lsp_utils")

return {
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    config = true,
  },
  -- Lazy-loads plugin completions
  {
    "folke/lazydev.nvim",
    ft = "lua",
    cmd = "LazyDev",
    dependencies = {
      {
        "DrKJeff16/wezterm-types",
        lazy = true,
        version = false,
        enabled = vim.g.is_wezterm or vim.fn.executable("wezterm") == 1,
      },
    },
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "wezterm-types",      mods = { "wezterm" } },
      },
    },
  },

  -- Mason configuration (LSP installer)
  -- Installed to "$HOME/.local/share/nvim/mason/bin"
  --              "%USERPROFILE%\AppData\Local\nvim-data\mason\bin"
  {
    "mason-org/mason.nvim",
    lazy = true,
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
    event = "VeryLazy",
    keys = {
      { "<leader>li", "<cmd>LspInfo<cr>",    desc = "[L]SP: [I]nfo" },
      { "<leader>lr", "<cmd>LspRestart<cr>", desc = "[L]SP: [R]estart active" },
    },
    dependencies = {
      {
        -- Mason-LSPConfig bridge
        "mason-org/mason-lspconfig.nvim",
        dependencies = { "mason-org/mason.nvim" },
        opts = {
          -- Calls vim.lsp.enable for every installed LSP
          automatic_enable = true,
          ensure_installed = {},
        },
      },
    },
    config = function()
      -- LSP-specific keymaps that should be attached once the client is known
      local lsp_keymap_config = require("plugins.lsp.lsp_keymaps")

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
          local filetype = vim.bo[bufnr].filetype

          lsp_keymap_config(client)

          -- From Neovim docs: prefer LSP folding if available
          if client:supports_method("textDocument/foldingRange") then
            vim.opt_local.foldmethod = "expr"
            vim.opt_local.foldexpr = "v:lua.vim.lsp.foldexpr()"
          end
        end,
      })

      -- Shared configurations + capabilities
      ---@type vim.lsp.Config
      local global_configs = {
        capabilities = lsp_utils.get_full_capabilities(),
        root_markers = { ".git" },
        settings = {
          telemetry = { enable = false },
        },
      }
      vim.lsp.config("*", global_configs)

      -- To have server-specific configurations, either create a file in
      --   .config/nvim/lsp/server_name.lua (preferred), or set up using vim.lsp.config.
      -- Using the former prevents timing issues with lazy loading configurations.

      -- Enable LSPs to attach when their respective filetypes are opened
      -- Need to explicitly add to this list if not installed via Mason
      vim.lsp.enable({
        "lua_ls",
        "gopls",
        "clangd",
        "basedpyright",
        "pyright",
        "ts_ls",
        "bashls",
      })

      vim.lsp.inlay_hint.enable()
    end,
  },
}
