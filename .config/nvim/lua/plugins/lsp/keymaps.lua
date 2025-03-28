-- .config/nvim/lua/plugins/lsp/keymaps.lua
-- Define keymaps for interacting with the LSPs

local M = {}

-- Format for keymaps: { mode = "n", key="", action=, desc=}
-- Action can be a function reference, function reference, or string
M.keymaps = {
  { mode = "n", key = "gd",         action = vim.lsp.buf.definition,      desc = "[G]oto [D]efinition" },
  { mode = "n", key = "gi",         action = vim.lsp.buf.implementation,  desc = "[G]oto [I]mplementation" },
  { mode = "n", key = "<leader>gt", action = vim.lsp.buf.type_definition, desc = "[G]oto [T]ype Definition" },
  { mode = "n", key = "<leader>gr", action = vim.lsp.buf.references,      desc = "[G]oto [R]eferences" },
  { mode = "n", key = "<leader>k",  action = vim.lsp.buf.hover,           desc = "Show documentation" },
  { mode = "n", key = "<leader>ds", action = vim.lsp.buf.document_symbol, desc = "[D]ocument [S]ymbols" },
  { mode = "n", key = "<leader>ca", action = vim.lsp.buf.code_action,     desc = "[C]ode [A]ctions" },
  { mode = "n", key = "<leader>rn", action = vim.lsp.buf.rename,          desc = "[R]e[n]ame symbol" },
  {
    mode = "v",
    key = "<leader>ca",
    action = function()
      vim.lsp.buf.code_action({ context = { only = { "quickfix", "refactor", "source" } } })
    end,
    desc = "Range [C]ode [A]ctions"
  },
  {
    mode = "n",
    key = "<leader>f",
    action = vim.lsp.buf.format,
    desc = "[F]ormat code"
  },
  { mode = "n", key = "<leader>dd", action = vim.diagnostic.open_float, desc = "[D]iagnostic [D]etails" },
  { mode = "n", key = "<leader>df", action = vim.diagnostic.setqflist,  desc = "[D]iagnostic [F]ix" },
  { mode = "n", key = "[d",         action = vim.diagnostic.goto_prev,  desc = "Previous diagnostic" },
  { mode = "n", key = "]d",         action = vim.diagnostic.goto_next,  desc = "Next diagnostic" },
}

local function create_keymap(mode, key, action, bufnr, desc)
  vim.keymap.set(mode, key, action, {
    buffer = bufnr,
    noremap = true,
    silent = true,
    desc = desc,
  })
end

function M.on_attach(client, bufnr)
  for _, km in ipairs(M.keymaps) do
    create_keymap(km.mode, km.key, km.action, bufnr, km.desc)
  end

  -- Client-specific keymaps
  if client.name == "gopls" then
    create_keymap("n", "<leader>ru", function()
      vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } } })
    end, bufnr, "[R]emove [U]nused imports (Go)")
  end
end

return M
