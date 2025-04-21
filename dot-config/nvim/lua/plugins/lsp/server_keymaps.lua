-- .config/nvim/lua/plugins/lsp/keymaps.lua
-- Set LSP specific keymaps once LspAttach occurs

local lsp = vim.lsp
local diagnostic = vim.diagnostic

---@param mode string|string[]     -- Mode: e.g. "n", "i", or {"n", "v"}
---@param lhs string               -- Key combination (e.g. "<leader>f")
---@param action string|fun():nil|fun(...):any      -- Function, string command, or Lua expression
---@param desc string              -- Description for which-key
local function map(mode, lhs, action, desc)
  vim.keymap.set(mode, lhs, action, { desc = desc, noremap = true, silent = true })
end

---@type table<string, function>
local setup_funcs = {
  gopls = function()
    map("n", "<leader>ru", function()
      lsp.buf.code_action({
        context = {
          diagnostics = diagnostic.get(0),
          only = { "source.organizeImports" }
        },
        apply = true,
      })
    end, "Go: [R]emove [U]nused imports")
  end,
  pyright = function()
    map("n", "<leader>oi", "<cmd>PyrightOrganizeImports<cr>", "Python: [O]rganize [I]mports")
  end,
  clangd = function()
    map("n", "<leader>si", "<cmd>ClangdShowSymbolInfo<cr>", "C: show [S]ymbol [I]nfo")
    map("n", "<leader>sh", "<cmd>ClangdSwitchSourceHeader<cr>", "C: switch [S]ource/[H]eader")
  end,
}

return function(client)
  local setup_func = setup_funcs[client.name]
  if setup_func then
    setup_func()
  end
end
