-- .config/nvim/plugins/lsp/config.lua
-- Global configurations applied to all LSPs

-- Toggle for auto-formatting on save
local auto_format_on_save = false

-- Attached on each LSP client
local function on_attach(client, bufnr)
  require("plugins.lsp.keymaps")(client, bufnr)

  if auto_format_on_save and client.supports_method("textDocument/formatting") then
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function() vim.lsp.buf.format({ async = false }) end,
    })
  end
end

local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Return overrides of vim.lsp.ClientConfig
return {
  on_attach = on_attach,
  capabilities = capabilities,
  offset_encoding = "utf-16",
  settings = {
    telemetry = { enable = false },
    completions = {
      completeFunctionCalls = true,
      triggerCompletionOnInsert = true,
    },
  },
}
