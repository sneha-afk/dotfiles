-- .config/nvim/lua/plugins/lsp/keymaps.lua
-- Define keymaps for interacting with the LSPs

local M = {}

-- List of key mappings
M.key_mappings = {
  { key = "f", action = "vim.lsp.buf.format()", desc = "Format code" },
  { key = "<leader>k", action = "vim.lsp.buf.hover()", desc = "Show documentation" },
  { key = "gd", action = "vim.lsp.buf.definition()", desc = "Go to definition" },
  { key = "gi", action = "vim.lsp.buf.implementation()", desc = "Go to implementation" },
  { key = "<leader>rn", action = "vim.lsp.buf.rename()", desc = "Rename symbol" },
  { key = "<leader>ca", action = "vim.lsp.buf.code_action()", desc = "Show code actions" },
  { key = "<leader>gr", action = "vim.lsp.buf.references()", desc = "Show references" },
  { key = "<leader>gt", action = "vim.lsp.buf.type_definition()", desc = "Go to type definition" },
  { key = "<leader>dl", action = "vim.diagnostic.open_float()", desc = "Show line diagnostics" },
  { key = "[d", action = "vim.diagnostic.goto_prev()", desc = "Go to previous diagnostic" },
  { key = "]d", action = "vim.diagnostic.goto_next()", desc = "Go to next diagnostic" },
}

-- Function to set keymaps
M.set_keymaps = function(bufnr)
  local opts = { noremap = true, silent = true }
  
  -- Iterate over key mappings and set them
  for _, mapping in ipairs(M.key_mappings) do
    vim.api.nvim_buf_set_keymap(bufnr, "n", mapping.key, "<Cmd>lua " .. mapping.action .. "<CR>", vim.tbl_extend("force", opts, { desc = mapping.desc }))
  end
end

return M