-- .config/nvim/lua/plugins/lsp/init.lua
-- Initialization of the LSP configuration with Mason, completes, and nvim-lspconfig

-- What to install through Mason
local servers_to_install = { "lua_ls", "vimls" }

-- Language files that LSPs should be enabled for (reduces startup for non-LSP configured files)
local lsp_languages = { "lua", "vim", "c", "cpp", "h", "hpp", "python", "go", "sh", "bash", "zsh" }

return {
  -- Mason configuration (LSP installer)
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

  -- LSP configurations: both externally installed and from Mason
  {
    "neovim/nvim-lspconfig",
    ft = lsp_languages,
    cmd = { "LspInfo" },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      local shared_configs = require("plugins.lsp.config")
      local server_overrides = require("plugins.lsp.server_configs")

      -- Setup diagnostics
      vim.diagnostic.config({
        update_in_insert = true,
        virtual_text = {
          spacing = 4,
          source = "if_many",
        },
        severity_sort = true,
        float = {
          border = "rounded",
          padding = 3,
          header = "",
          title = " Diagnostics "
        },
      })

      for server_name, overrides in pairs(server_overrides) do
        require("lspconfig")[server_name].setup(
          vim.tbl_deep_extend("force",
            shared_configs, -- Shared configuration
            overrides       -- Server-specific overrides
          )
        )
      end

      -- Auto-clear LSP logs after 10MB
      vim.api.nvim_create_autocmd({ "VimEnter", "BufEnter" }, {
        callback = function()
          local log_path = vim.fn.stdpath("log") .. "/lsp.log"
          local max_size = 10 * 1024 * 1024

          local ok, stats = pcall((vim.uv or vim.loop).fs_stat, log_path)
          if ok and stats and stats.size > max_size then
            local file = io.open(log_path, "w")
            if file then
              file:close()
              vim.notify("Cleared LSP log (>10MB)", vim.log.levels.INFO)
            end
          end
        end,
        desc = "Clear oversized LSP logs"
      })
    end
  },
}
