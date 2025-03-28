-- .config/nvim/lua/plugins/lsp/handlers.lua

local M = {}

M.common_ui = {
  border = "rounded",
  focusable = true,
  padding = { 1, 2, 1, 2 },
  trim_empty_lines = true,
  max_width = 80,
  max_view_entries = 7,
}

-- textDocument handlers that are floats
M.float_handlers = {
  "hover",
  "signatureHelp",
  "documentSymbol"
}

M.setup = function()
  -- Style standard floating handlers
  for _, handler in ipairs(M.float_handlers) do
    vim.lsp.handlers["textDocument/" .. handler] = vim.lsp.with(vim.lsp.handlers[handler], M.common_ui)
  end

  vim.diagnostic.config({ float = M.common_ui })
end

return M
