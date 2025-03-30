-- .config/nvim/lua/plugins/lsp/handlers.lua
-- See https://neovim.io/doc/user/lsp.html#_lsp-api

local M = {}

M.common_ui = {
  border = "rounded",
  focusable = true,
  padding = { 1, 2, 1, 2 },
  trim_empty_lines = true,
  max_width = 100,
}

-- textDocument/name -> ACTUAL vim.lsp.handlers.function_name
-- name = function_name
M.float_handlers = {
  hover = "hover",
  signatureHelp = "signature_help",
}

M.setup = function()
  for doc_name, handler_name in pairs(M.float_handlers) do
    vim.lsp.handlers["textDocument/" .. doc_name] = vim.lsp.with(
      vim.lsp.handlers[handler_name],
      M.common_ui
    )
  end
end

return M
