-- .config/nvim/lua/lsp/init.lua

---Figures out which completion environment is being used to extend capabilities
---@return lsp.ClientCapabilities
local function get_capabilities_source()
  if pcall(require, "blink.cmp") then
    return require("blink.cmp").get_lsp_capabilities({}, false)
  elseif pcall(require, "cmp_nvim_lsp") then
    return require("cmp_nvim_lsp").default_capabilities()
  else
    return {}
  end
end

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
    event = { "VeryLazy", "InsertEnter" },
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
        capabilities = vim.tbl_deep_extend("force",
          vim.lsp.protocol.make_client_capabilities(),
          get_capabilities_source()
        ),
        root_markers = { ".git" },
        settings = {
          telemetry = { enable = false },
        },
      }
      vim.lsp.config("*", global_configs)

      -- Use vim.lsp.config for further configuration
      require("plugins.lsp.lsp_server_configs")

      -- Enable LSPs to attach when their respective filetypes are opened
      -- Need to explicitly add to this list if not installed via Mason
      vim.lsp.enable({
        "lua_ls",
        "gopls",
        "clangd",
        "pyright",
        "ts_ls",
        "bashls",
      })

      vim.lsp.inlay_hint.enable()

      ---@type vim.diagnostic.Opts
      local diagnostic_opts = {
        update_in_insert = true,
        virtual_text = {
          spacing = 2,
          source = "if_many",
        },
        severity_sort = true,
        float = {
          border = "rounded",
          header = "",
          title = " Diagnostics ",
          source = "if_many",
        },
      }
      vim.diagnostic.config(diagnostic_opts)
    end,
  },
}
