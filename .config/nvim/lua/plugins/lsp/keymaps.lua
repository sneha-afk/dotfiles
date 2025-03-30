-- .config/nvim/lua/plugins/lsp/keymaps.lua
-- Define keymaps for interacting with the LSPs

local M = {}

-- Format for keymaps: { mode = "n", key="", action=, desc=}
-- Action can be a function reference, function reference, or string
-- Some of these are already defaults, but overwritten to change their description
M.keymaps = {
  -- Navigation
  { mode = "n", key = "gd",         action = vim.lsp.buf.definition,              desc = "[G]oto [D]efinition" },
  { mode = "n", key = "gD",         action = vim.lsp.buf.declaration,             desc = "[G]oto [D]eclaration" },
  { mode = "n", key = "gi",         action = vim.lsp.buf.implementation,          desc = "[G]oto [I]mplementation" },
  { mode = "n", key = "gy",         action = vim.lsp.buf.type_definition,         desc = "[G]oto t[y]pe definition" },
  { mode = "n", key = "gr",         action = vim.lsp.buf.references,              desc = "[G]oto [R]eferences" },
  { mode = "n", key = "gI",         action = vim.lsp.buf.incoming_calls,          desc = "[G]oto [I]ncoming calls" },
  { mode = "n", key = "gO",         action = vim.lsp.buf.outgoing_calls,          desc = "[G]oto [O]utgoing calls" },

  -- Documentation
  { mode = "n", key = "K",          action = vim.lsp.buf.hover,                   desc = "Hover Documentation" },
  { mode = "i", key = "<C-k>",      action = vim.lsp.buf.signature_help,          desc = "Signature Documentation" },

  -- Workspace
  { mode = "n", key = "<leader>wa", action = vim.lsp.buf.add_workspace_folder,    desc = "[W]orkspace [A]dd Folder" },
  { mode = "n", key = "<leader>wr", action = vim.lsp.buf.remove_workspace_folder, desc = "[W]orkspace [R]emove Folder" },
  {
    mode = "n",
    key = "<leader>wl",
    action = function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end,
    desc = "[W]orkspace [L]ist Folders"
  },

  -- Code Actions
  { mode = "n", key = "<leader>ca", action = vim.lsp.buf.code_action,      desc = "[C]ode [A]ction" },
  {
    mode = "v",
    key = "<leader>ca",
    action = function()
      vim.lsp.buf.code_action({ context = { only = { "quickfix", "refactor", "source" } } })
    end,
    desc = "Range [C]ode [A]ctions"
  },

  -- Symbols
  { mode = "n", key = "<leader>ds", action = vim.lsp.buf.document_symbol,  desc = "[D]ocument [S]ymbols" },
  { mode = "n", key = "<leader>ws", action = vim.lsp.buf.workspace_symbol, desc = "[W]orkspace [S]ymbols" },

  -- Refactoring
  { mode = "n", key = "<leader>rn", action = vim.lsp.buf.rename,           desc = "[R]e[n]ame" },
  { mode = "n", key = "<leader>fc", action = vim.lsp.buf.format,           desc = "[F]ormat [C]ode" },

  -- Diagnostics
  { mode = "n", key = "<leader>dl", action = vim.diagnostic.open_float,    desc = "Open [D]iagnostic [L]ist" },
  { mode = "n", key = "[d",         action = vim.diagnostic.goto_prev,     desc = "Previous diagnostic" },
  { mode = "n", key = "]d",         action = vim.diagnostic.goto_next,     desc = "Next diagnostic" },
  { mode = "n", key = "<leader>df", action = vim.diagnostic.setloclist,    desc = "[D]iagnostics to quick[f]ix" },
  {
    mode = "n",
    key = "<leader>dt",
    action = function()
      vim.diagnostic.enable(not vim.diagnostic.is_enabled())
    end,
    desc = "[D]iagonstic [T]oggle"
  },

  -- Management
  { mode = "n", key = "<leader>li", action = "<cmd>LspInfo<cr>",    desc = "[L]SP [I]nfo" },
  { mode = "n", key = "<leader>lr", action = "<cmd>LspRestart<cr>", desc = "[L]SP [R]estart" },
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
