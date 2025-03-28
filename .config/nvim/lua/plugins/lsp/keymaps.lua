-- .config/nvim/lua/plugins/lsp/keymaps.lua
-- Define keymaps for interacting with the LSPs

local M = {}

M.key_mappings = {
  -- Code navigation
  { key = "gd",         action = "vim.lsp.buf.definition()",       desc = "[G]oto [D]efinition" },
  { key = "gi",         action = "vim.lsp.buf.implementation()",   desc = "[G]oto [I]mplementation" },
  { key = "<leader>gt", action = "vim.lsp.buf.type_definition()",  desc = "[G]oto [T]ype Definition" },
  { key = "<leader>gr", action = "vim.lsp.buf.references()",       desc = "[G]oto [R]eferences" },

  -- Documentation
  { key = "K",          action = "vim.lsp.buf.hover()",            desc = "Show documentation" },
  { key = "<leader>ds", action = "vim.lsp.buf.document_symbol()",  desc = "[D]ocument [S]ymbols" },
  { key = "<leader>ws", action = "vim.lsp.buf.workspace_symbol()", desc = "[W]orkspace [S]ymbols" },

  -- Code actions
  { key = "<leader>ca", action = "vim.lsp.buf.code_action()",      desc = "[C]ode [A]ctions" },
  { key = "<leader>rn", action = "vim.lsp.buf.rename()",           desc = "[R]e[n]ame symbol" },

  -- Formatting
  { key = "<leader>f",  action = "vim.lsp.buf.format()",           desc = "[F]ormat code" },

  -- Diagnostics
  { key = "<leader>dl", action = "vim.diagnostic.open_float()",    desc = "[D]iagnostic [L]ine" },
  { key = "<leader>dq", action = "vim.diagnostic.setqflist()",     desc = "[D]iagnostic [Q]uickfixes" },
  { key = "[d",         action = "vim.diagnostic.goto_prev()",     desc = "Previous diagnostic" },
  { key = "]d",         action = "vim.diagnostic.goto_next()",     desc = "Next diagnostic" },
}

--- Set up LSP keymaps for a buffer
function M.on_attach(client, bufnr)
  local opts = { buffer = bufnr, noremap = true, silent = true }

  -- Set each key mapping
  for _, mapping in ipairs(M.key_mappings) do
    vim.keymap.set(
      "n",
      mapping.key,
      function() vim.cmd.lua(mapping.action) end,
      vim.tbl_extend("force", opts, { desc = mapping.desc })
    )
  end

  -- Client-specific keymaps
  if client.name == "gopls" then
    vim.keymap.set("n", "<leader>ru", function()
      vim.lsp.buf.code_action({
        context = { only = { "source.organizeImports" } },
        apply = true,
      })
    end, vim.tbl_extend("force", opts, { desc = "[R]emove [U]nused imports (Go)" }))
  end
end

return M
