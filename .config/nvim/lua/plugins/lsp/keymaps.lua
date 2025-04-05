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
  { mode = "i", key = "<C-k>",      action = vim.lsp.buf.signature_help,          desc = "[S]ignature [H]elp" },
  { mode = "n", key = "<leader>sh", action = vim.lsp.buf.signature_help,          desc = "[S]ignature [H]elp (normal mode)" },

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
  { mode = "n", key = "<leader>rn", action = vim.lsp.buf.rename,      desc = "[R]e[n]ame Symbol" },
  { mode = "n", key = "<leader>fc", action = vim.lsp.buf.format,      desc = "[F]ormat [C]ode" },
  { mode = "n", key = "<leader>ca", action = vim.lsp.buf.code_action, desc = "[C]ode [A]ctions" },
  {
    mode = "v",
    key = "<leader>ca",
    action = function()
      vim.lsp.buf.code_action({
        diagnostics = vim.lsp.diagnostic.get_line_diagnostics(),
        only = { "quickfix", "refactor", "source" }
      })
    end,
    desc = "Range [C]ode [A]ctions"
  },
  {
    mode = "n",
    key = "<leader>oi",
    action = function()
      vim.lsp.buf.code_action({
        diagnostics = vim.lsp.diagnostic.get_line_diagnostics(),
        only = { "quickfix", "refactor", "source" }
      })
    end,
    desc = "[O]rganize [I]mports"
  },

  -- Symbols
  { mode = "n", key = "<leader>ds", action = vim.lsp.buf.document_symbol,  desc = "[D]ocument [S]ymbols" },
  { mode = "n", key = "<leader>ws", action = vim.lsp.buf.workspace_symbol, desc = "[W]orkspace [S]ymbols" },

  -- Diagnostics
  { mode = "n", key = "<leader>dl", action = vim.diagnostic.open_float,    desc = "Open [D]iagnostic [L]ist" },
  { mode = "n", key = "[d",         action = vim.diagnostic.goto_prev,     desc = "Previous diagnostic" },
  { mode = "n", key = "]d",         action = vim.diagnostic.goto_next,     desc = "Next diagnostic" },
  { mode = "n", key = "<leader>df", action = vim.diagnostic.setloclist,    desc = "[D]iagnostics: [f]ile-local list" },
  {
    mode = "n",
    key = "<leader>dt",
    action = function()
      vim.diagnostic.config({ virtual_text = not vim.diagnostic.config().virtual_text })
    end,
    desc = "[D]iagnostic [T]oggle"
  },
  {
    mode = "n",
    key = "<leader>da",
    action = function()
      vim.diagnostic.setqflist({ open = true })
    end,
    desc = "[D]iagnostics : see [A]ll project-wide"
  },

  -- Management
  { mode = "n", key = "<leader>li", action = "<cmd>LspInfo<cr>",    desc = "[L]SP [I]nfo" },
  { mode = "n", key = "<leader>lr", action = "<cmd>LspRestart<cr>", desc = "[L]SP [R]estart" },
  { mode = "n", key = "<leader>cl", action = vim.lsp.codelens.run,  desc = "[C]ode[L]ens Run" },
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
      vim.lsp.buf.code_action({
        context = {
          diagnostics = vim.lsp.diagnostic.get_line_diagnostics(),
          only = { "source.organizeImports" }
        }
      })
    end, bufnr, "[R]emove [U]nused imports (Go)")
  end
end

return M
