-- .config/nvim/lua/plugins/lsp/keymaps.lua
-- Set LSP specific keymaps once LspAttach occurs

local lsp = vim.lsp
local diagnostic = vim.diagnostic

---@param mode string|string[]     -- Mode: e.g. "n", "i", or {"n", "v"}
---@param lhs string               -- Key combination (e.g. "<leader>f")
---@param action string|fun():nil|fun(...):any      -- Function, string command, or Lua expression
---@param opts table               -- Options table (include "desc" for which-key)
local function map(mode, lhs, action, opts)
  opts = vim.tbl_extend("force", {
    noremap = true,
    silent = true,
  }, opts or {})

  vim.keymap.set(mode, lhs, action, opts)
end

---@type table<string, function>
local setup_funcs = {
  gopls = function()
    map("n", "<leader>oi", function()
      lsp.buf.code_action({
        context = {
          diagnostics = diagnostic.get(0),
          only = { "source.organizeImports" }
        },
        apply = true,
      })
    end, { desc = "Go: [O]rganize [I]mports" })
  end,
  pyright = function()
    map("n", "<leader>oi", "<cmd>PyrightOrganizeImports<cr>", { desc = "Python: [O]rganize [I]mports" })
  end,
  clangd = function()
    map("n", "<leader>si", "<cmd>ClangdShowSymbolInfo<cr>", { desc = "C: show [S]ymbol [I]nfo" })
    map("n", "<leader>sh", "<cmd>ClangdSwitchSourceHeader<cr>", { desc = "C: switch [S]ource/[H]eader" })
  end,
}

return function(client)
  local setup_func = setup_funcs[client.name]
  if setup_func then
    setup_func()
  end
end
