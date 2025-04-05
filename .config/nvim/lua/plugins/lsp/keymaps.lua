-- .config/nvim/lua/plugins/lsp/keymaps.lua
-- Define keymaps for interacting with the LSPs

local lsp = vim.lsp
local diagnostic = vim.diagnostic

local float_ui = {
  border = "rounded",
  focusable = true,
  padding = { 2, 2, 2, 2 },
  trim_empty_lines = true,
  max_width = 100,
  title = " LSP Info ",
  title_pos = "center",
}

local M = {}

-- Format for keymaps: { mode = "n", key="", action=, desc=}
-- Action can be a Lua function, function reference, or string
-- Some of these are already defaults, but overwritten to change their description
M.keymaps = {
  -- Navigation
  { "n", "gd",         lsp.buf.definition,                                         "[G]oto [D]efinition" },
  { "n", "gD",         lsp.buf.declaration,                                        "[G]oto [D]eclaration" },
  { "n", "gi",         lsp.buf.implementation,                                     "[G]oto [I]mplementation" },
  { "n", "gy",         lsp.buf.type_definition,                                    "[G]oto t[y]pe definition" },
  { "n", "gr",         lsp.buf.references,                                         "[G]oto [R]eferences" },
  { "n", "gI",         lsp.buf.incoming_calls,                                     "[G]oto [I]ncoming calls" },
  { "n", "gO",         lsp.buf.outgoing_calls,                                     "[G]oto [O]utgoing calls" },

  -- Documentation
  { "n", "K",          function() lsp.buf.hover(float_ui) end,                     "Hover Documentation" },
  { "i", "<C-k>",      function() lsp.buf.signature_help(float_ui) end,            "[S]ignature [H]elp" },
  { "n", "<C-k>",      function() lsp.buf.signature_help(float_ui) end,            "[S]ignature [H]elp (normal mode)" },

  -- Workspace
  { "n", "<leader>wa", lsp.buf.add_workspace_folder,                               "[W]orkspace [A]dd Folder" },
  { "n", "<leader>wr", lsp.buf.remove_workspace_folder,                            "[W]orkspace [R]emove Folder" },
  { "n", "<leader>wl", function() vim.print(lsp.buf.list_workspace_folders()) end, "[W]orkspace [L]ist Folders" },

  -- Code Actions
  { "n", "<leader>rn", lsp.buf.rename,                                             "[R]e[n]ame Symbol" },
  { "n", "<leader>cf", lsp.buf.format,                                             "[C]ode [F]ormat" },
  { "n", "<leader>ca", lsp.buf.code_action,                                        "[C]ode [A]ctions" },
  { "v", "<leader>ca", function()
    lsp.buf.code_action({
      diagnostics = lsp.diagnostic.get_line_diagnostics(),
      only = { "quickfix", "refactor", "source" }
    })
  end, "Range [C]ode [A]ctions" },

  -- Symbols
  { "n", "<leader>ds", lsp.buf.document_symbol,                       "[D]ocument [S]ymbols" },
  { "n", "<leader>ws", lsp.buf.workspace_symbol,                      "[W]orkspace [S]ymbols" },

  -- Diagnostics
  { "n", "<leader>dl", diagnostic.open_float,                         "Open [D]iagnostic [L]ist" },
  { "n", "<leader>df", diagnostic.setloclist,                         "[D]iagnostics: [f]ile-local list" },
  { "n", "[d",         function() diagnostic.jump { count = -1 } end, "Previous diagnostic" },
  { "n", "]d",         function() diagnostic.jump { count = 1 } end,  "Next diagnostic" },
  { "n", "<leader>dt", function()
    diagnostic.config({ virtual_text = not diagnostic.config().virtual_text })
  end, "[D]iagnostic [T]oggle" },
  { "n", "<leader>da", function() diagnostic.setqflist({ open = true }) end, "[D]iagnostics: see [A]ll project-wide" },

  -- Management
  { "n", "<leader>li", "<cmd>LspInfo<cr>",                                   "[L]SP [I]nfo" },
  { "n", "<leader>lr", "<cmd>LspRestart<cr>",                                "[L]SP [R]estart" },
  { "n", "<leader>cl", lsp.codelens.run,                                     "[C]ode[L]ens Run" },
}

M.client_specific = {
  gopls = {
    { "n", "<leader>ru", function()
      lsp.buf.code_action({
        context = {
          diagnostics = lsp.diagnostic.get_line_diagnostics(),
          only = { "source.organizeImports" }
        }
      })
    end, "[R]emove [U]nused imports (Go)" }
  }
}

function M.on_attach(client, bufnr)
  -- General keymaps applied to all LSPs
  for _, km in ipairs(M.keymaps) do
    vim.keymap.set(km[1], km[2], km[3], {
      buffer = bufnr,
      desc = km[4],
      noremap = true,
      silent = true,
    })
  end

  -- Set any client-specific keymaps
  local client_keymaps = M.client_specific[client.name]
  if client_keymaps then
    for _, km in ipairs(client_keymaps) do
      vim.keymap.set(km[1], km[2], km[3], {
        buffer = bufnr,
        desc = km[4],
        noremap = true,
        silent = true,
      })
    end
  end
end

return M
