-- .config/nvim/lua/plugins/lsp/handlers.lua

local M = {}

M.common_ui = {
  border = "rounded",
  focusable = true,
  padding = { 1, 2, 1, 2 },
  max_width = 80
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
    local lsp_handler = vim.lsp.handlers[handler]
    if lsp_handler then
      vim.lsp.handlers["textDocument/" .. handler] = vim.lsp.with(lsp_handler, M.common_ui)
    end
  end

  vim.diagnostic.config({ float = M.common_ui })
end

return M
