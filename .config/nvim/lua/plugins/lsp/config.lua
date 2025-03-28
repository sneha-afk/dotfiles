-- .config/nvim/plugins/lsp/config.lua
-- Common configurations for LSPs

local M = {}

-- Toggle for auto-formatting on save
M.auto_format_on_save = false

M.capabilities = require("cmp_nvim_lsp").default_capabilities()

M.on_attach = function(client, bufnr)
  require("plugins.lsp.keymaps").on_attach(client, bufnr)

  if M.auto_format_on_save and client.supports_method("textDocument/formatting") then
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ async = false })
      end
    })
  end

  -- Auto show LSP diagnostics when hovering
  vim.api.nvim_create_autocmd("CursorHold", {
    pattern = "*",
    callback = function()
      vim.diagnostic.open_float({ focusable = false, close_events = { "BufLeave", "CursorMoved" } })
    end,
    desc = "Automatically show LSP diagnostics",
  })
end

M.default_config = {
  on_attach = M.on_attach,
  capabilities = M.capabilities,
  flags = {
    debounce_text_changes = 150,
    allow_incremental_sync = true,
  },
  settings = {
    telemetry = { enable = false },
  },
}

return M
