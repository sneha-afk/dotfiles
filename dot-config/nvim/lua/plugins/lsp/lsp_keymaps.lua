-- .config/nvim/lua/lsp/lsp_keymaps.lua
-- Set LSP specific keymaps once LspAttach occurs

local map = vim.keymap.set
local lsp = vim.lsp
local diagnostic = vim.diagnostic

local organize_imports = function()
  lsp.buf.code_action({
    context = {
      diagnostics = diagnostic.get(0),
      only = { "source.organizeImports" },
    },
    apply = true,
  })
end

vim.api.nvim_create_user_command("OrganizeImports", organize_imports,
  { desc = "Organize imports via LSP (if supported)" })

---@type table<string, function>
local setup_funcs = {
  gopls = function()
    map("n", "<leader>oi", organize_imports, { desc = "Go: [O]rganize [I]mports" })
  end,
  basedpyright = function()
    map("n", "<leader>oi", "<cmd>LspPyrightOrganizeImports<cr>",
      { desc = "Python: [O]rganize [I]mports" })
  end,
  pyright = function()
    map("n", "<leader>oi", "<cmd>LspPyrightOrganizeImports<cr>",
      { desc = "Python: [O]rganize [I]mports" })
  end,
  clangd = function()
    map("n", "<leader>si", "<cmd>LspClangdShowSymbolInfo<cr>",     { desc = "C: show [S]ymbol [I]nfo" })
    map("n", "<leader>sh", "<cmd>LspClangdSwitchSourceHeader<cr>", { desc = "C: switch [S]ource/[H]eader" })
  end,
  ts_ls = function()
    map("n", "<leader>oi",  organize_imports,                             { desc = "JS/TS: [O]rganize [I]mports" })
    map("n", "<leader>cas", "<cmd>LspTypescriptSourceAction<cr>",         { desc = "JS/TS: [CA]ctions, [S]ource" })
    map("n", "<leader>gsd", "<cmd>LspTypescriptGoToSourceDefinition<cr>", { desc = "JS/TS: [G]oto [S]ource [D]efinition" })
  end,
}

---@param client vim.lsp.Client Which client to setup keymaps for (if defined)
return function(client)
  local setup_func = setup_funcs[client.name]
  if setup_func then setup_func() end
end
