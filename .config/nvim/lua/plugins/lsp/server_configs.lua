-- .config/nvim/lua/plugins/lsp/server_configs.lua
-- Define any overrides from the default neovim-lspconfig, and map keymaps for each server

local lspconfig = require("lspconfig")
local keymaps = require("plugins.lsp.keymaps")
local cmp_nvim_lsp = require("cmp_nvim_lsp")

-- Custom configurations to override from default nvim-lspconfig
-- List all LSPs needed here, keep empty if default settings are fine
local servers = {
  pyright = {
    settings = {
      pyright = {
        typeCheckingMode = "basic",
        useLibraryCodeForTypes = true,
      },
    },
  },

  gopls = {
    settings = {
      gopls = {
        staticcheck = true,
        usePlaceholders = true,
        completeUnimported = true,
        semanticTokens = true,
        analyses = {
          nilness = true,
          unusedwrite = true,
          unreachable = true,
          useany = true,
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
          imports = true,
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

-- Caching capabilities and keymap attachments
local capabilities = cmp_nvim_lsp.default_capabilities()
local attach_keys = function(client, bufnr)
  keymaps.set_keymaps(bufnr)

  -- Go-specific keymaps
  if client.name == "gopls" then
    vim.keymap.set("n", "<leader>ru", function()
      vim.lsp.buf.code_action({
        context = { only = { "source.organizeImports" } },
        apply = true,
      })
    end, { buffer = bufnr, desc = "Remove unused imports (Go)" })
  end
end

-- Default configuration shared across all servers
local default_config = {
  on_attach = attach_keys,
  capabilities = capabilities,
  flags = {
    debounce_text_changes = 150,
    allow_incremental_sync = true,
  },
  handlers = {},
  settings = {
    telemetry = { enable = false },
  },
}

-- Apply unified settings to each handler's window
local text_document_handlers = {
  "hover",
  "signatureHelp",
  "definition",
  "rename",
}

for _, handler in ipairs(text_document_handlers) do
  default_config.handlers["textDocument/" .. handler] = vim.lsp.with(vim.lsp.handlers[handler], {
    border = "rounded",
    focusable = true,
    padding = { 1, 2, 1, 2 },
    wrap = true,
  })
end

-- Apply configurations
for server_name, config in pairs(servers) do
  if lspconfig[server_name] then
    lspconfig[server_name].setup(vim.tbl_deep_extend("force", default_config, config or {}))
  else
    vim.notify("LSP server not found: " .. server_name, vim.log.levels.WARN)
  end
end
