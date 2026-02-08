-- .config/nvim/lua/lsp/init.lua

-- Setup specific keymaps for servers
local server_maps = {
  basedpyright = {
    { "<leader>oi", "<cmd>PyrightOrganizeImports<cr>", desc = "Python: [O]rganize [I]mports" },
  },
  clangd = {
    { "<leader>si", "<cmd>ClangdSymbolInfo<cr>",         desc = "C: [S]ymbol [I]nfo" },
    { "<leader>sh", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "C: switch [S]ource/[H]eader" },
  },
  ts_ls = {
    { "<leader>cas", "<cmd>LspTypescriptSourceAction<cr>",         desc = "JS/TS: [CA]ctions, [S]ource" },
    { "gsd",         "<cmd>LspTypescriptGoToSourceDefinition<cr>", desc = "JS/TS: [G]oto [S]ource [D]efinition" },
  },
}
server_maps.pyright = server_maps.basedpyright

return {
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      notification = {
        view = {
          reflow = "hyphenate",
        },
        window = {
          max_width = 0.4,
        },
      },
    },
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    cmd = "LazyDev",
    dependencies = {
      {
        "DrKJeff16/wezterm-types",
        lazy = true,
        version = false,
        enabled = vim.fn.has("wsl") == 0 and (vim.g.is_wezterm or vim.fn.executable("wezterm") == 1),
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
    cmd = "Mason",
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
      local lsp_utils = require("utils.lsp_utils")

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

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then return end
          local bufnr = args.buf

          local server_specific_maps = server_maps[client.name]
          if server_specific_maps then
            for _, mapping in ipairs(server_specific_maps) do
              local opts = vim.tbl_extend("force", { buffer = bufnr }, mapping[3] or {})
              vim.keymap.set("n", mapping[1], mapping[2], opts)
            end
          end

          -- From Neovim docs: prefer LSP folding if available
          if client:supports_method("textDocument/foldingRange") then
            vim.opt_local.foldmethod = "expr"
            vim.opt_local.foldexpr = "v:lua.vim.lsp.foldexpr()"
          end

          if client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
          end
        end,
      })

      -- To have server-specific configurations, either create a file in
      --   .config/nvim/after/lsp/server_name.lua (preferred), or set up using vim.lsp.config.
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
        "eslint",
        "bashls",
      })
    end,
  },
}
