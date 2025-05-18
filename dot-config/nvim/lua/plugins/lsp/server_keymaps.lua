-- .config/nvim/lua/plugins/lsp/keymaps.lua
-- Set LSP specific keymaps once LspAttach occurs

local utils = require("core.utils")
local map = utils.set_keymap

local lsp = vim.lsp
local diagnostic = vim.diagnostic

---@type table<string, function>
local setup_funcs = {
  gopls = function()
    map("n", "<leader>oi",
      function()
        lsp.buf.code_action({
          context = {
            diagnostics = diagnostic.get(0),
            only = { "source.organizeImports" },
          },
          apply = true,
        })
      end, { desc = "Go: [O]rganize [I]mports" })
  end,
  pyright = function() map("n", "<leader>oi", "<cmd>LspPyrightOrganizeImports<cr>", { desc = "Python: [O]rganize [I]mports" }) end,
  clangd = function()
    map("n", "<leader>si", "<cmd>LspClangdShowSymbolInfo<cr>",     { desc = "C: show [S]ymbol [I]nfo" })
    map("n", "<leader>sh", "<cmd>LspClangdSwitchSourceHeader<cr>", { desc = "C: switch [S]ource/[H]eader" })
  end,
}

---@param client vim.lsp.Client Which client to setup keymaps for (if defined)
return function(client)
  local setup_func = setup_funcs[client.name]
  if setup_func then setup_func() end
end
