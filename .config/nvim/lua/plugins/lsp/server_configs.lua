-- .config/nvim/lua/plugins/lsp/server_configs.lua
-- Define any overrides from the default neovim-lspconfig, and map keymaps for each server

local lspconfig = require("lspconfig")
local keymaps = require("plugins.lsp.keymaps")

-- Caching capabilities and keymap attachments
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local attach_keys = function(client, bufnr)
  keymaps.set_keymaps(bufnr)
end

-- Default configuration shared across all servers
local default_config = {
  on_attach = attach_keys,
  capabilities = capabilities,
  flags = {
    debounce_text_changes = 150,
    allow_incremental_sync = true,
  },
  handlers = {
    ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" }),
    ["textDocument/signatureHelp"] = vim.lsp.with(
      vim.lsp.handlers.signature_help,
      { border = "rounded" }
    ),
  },
  settings = {
    telemetry = { enable = false },
  },
}

-- Custom configurations to override from default nvim-lspconfig
-- List all LSPs needed here, keep empty if default settings are fine
local servers = {
  pyright = {},

  gopls = {
    settings = {
      gopls = {
        staticcheck = true,
        completeUnimported = true,
        semanticTokens = true,
        analyses = {
          nilness = true,
          unusedwrite = true,
          unreachable = true,
          useany = true, -- Check for interface{} usage
          unusedvariable = true,
          fillreturns = true,
        },
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          constantValues = true,
          parameterNames = true,
        },
        codelenses = {
          generate = true,
          gc_details = true,
          test = true,
          tidy = true,
          upgrade_dependency = true,
          vendor = true,
        },
      },
    },
  },

  clangd = {
    cmd = { "clangd" },
    args = {
      "--clang-tidy",
      "--background-index",
      "--compile-commands-dir=build",
      "--header-insertion=never",
      "--all-scopes-completion",
      "--offset-encoding=utf-16",
    },
    init_options = {
      fallbackFlags = { "-std=c++11", "-Wall", "-Wextra", "-Wpedantic" },
      clangdFileStatus = true,
      usePlaceholders = true,
    },
    filetypes = { "c", "cpp", "h", "hpp" },
  },
}

-- Apply configurations
for server_name, config in pairs(servers) do
  if lspconfig[server_name] then
    lspconfig[server_name].setup(vim.tbl_deep_extend("force", default_config, config or {}))
  else
    vim.notify("LSP server not found: " .. server_name, vim.log.levels.WARN)
  end
end
