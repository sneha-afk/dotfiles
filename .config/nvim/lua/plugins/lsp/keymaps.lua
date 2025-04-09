-- .config/nvim/lua/plugins/lsp/keymaps.lua
-- Define keymaps for interacting with the LSPs

local lsp = vim.lsp
local diagnostic = vim.diagnostic

local float_ui = {
  border = "rounded",
  max_width = 100,
  title = " LSP Info ",
  title_pos = "center",
}

-- Format for keymaps: { mode = "n", key=, desc=, action=}
-- Action can be a Lua function, function reference, or string
-- Some of these are already defaults, but overwritten to change their description
local keymaps = {
  -- Navigation
  { "n", "gd",         "[G]oto [d]efinition",         lsp.buf.definition },
  { "n", "gD",         "[G]oto [D]eclaration",        lsp.buf.declaration },
  { "n", "gi",         "[G]oto [I]mplementation",     lsp.buf.implementation },
  { "n", "gy",         "[G]oto t[y]pe definition",    lsp.buf.type_definition },
  { "n", "gr",         "[G]oto [r]eferences",         lsp.buf.references },
  { "n", "gI",         "[G]oto [I]ncoming calls",     lsp.buf.incoming_calls },
  { "n", "gO",         "[G]oto [O]utgoing calls",     lsp.buf.outgoing_calls },

  -- Documentation
  { "n", "K",          "Open documentation float",    function() lsp.buf.hover(float_ui) end },
  { "i", "<C-k>",      "[S]ignature [H]elp",          function() lsp.buf.signature_help(float_ui) end },
  { "n", "<C-k>",      "[S]ignature [H]elp (normal)", function() lsp.buf.signature_help(float_ui) end },

  -- Workspace
  { "n", "<leader>wa", "[W]orkspace [A]dd Folder",    lsp.buf.add_workspace_folder },
  { "n", "<leader>wr", "[W]orkspace [R]emove Folder", lsp.buf.remove_workspace_folder },
  { "n", "<leader>wl", "[W]orkspace [L]ist Folders",  function() vim.print(lsp.buf.list_workspace_folders()) end },

  -- Code Actions
  { "n", "<leader>rn", "[R]e[n]ame Symbol",           lsp.buf.rename },
  { "n", "<leader>cf", "[C]ode [F]ormat",             lsp.buf.format },
  { "n", "<leader>ca", "[C]ode [A]ctions",            lsp.buf.code_action },
  { "v", "<leader>ca", "Range [C]ode [A]ctions",
    function()
      lsp.buf.code_action({
        diagnostics = diagnostic.get(0),
        only = { "quickfix", "refactor", "source" }
      })
    end
  },

  -- Symbols
  { "n", "<leader>ds", "[D]ocument [S]ymbols",  lsp.buf.document_symbol },
  { "n", "<leader>ws", "[W]orkspace [S]ymbols", lsp.buf.workspace_symbol },

  -- Management
  { "n", "<leader>li", "[L]SP [I]nfo",          "<cmd>LspInfo<cr>" },
  { "n", "<leader>lr", "[L]SP [R]estart",       "<cmd>LspRestart<cr>" },
  { "n", "<leader>cl", "Run [C]ode[L]ens",      lsp.codelens.run },
}

local client_specific = {
  gopls = {
    { "n", "<leader>ru", "Go: [R]emove [U]nused imports",
      function()
        lsp.buf.code_action({
          context = {
            diagnostics = diagnostic.get(0),
            only = { "source.organizeImports" }
          },
          apply = true,
        })
      end
    },
  },
  pyright = {
    { "n", "<leader>oi", "Python: [O]rganize [I]mports", "<cmd>PyrightOrganizeImports<cr>" },
  },
}

local function map(mode, short, action, desc, bufnr)
  vim.keymap.set(mode, short, action, {
    buffer = bufnr,
    desc = desc,
    noremap = true,
    silent = true,
  })
end

return function(client, bufnr)
  -- General keymaps applied to all LSPs
  for _, km in ipairs(keymaps) do
    map(km[1], km[2], km[4], km[3], bufnr)
  end

  -- Client-specific keymaps
  local client_keymaps = client_specific[client.name]
  if client_keymaps then
    for _, km in ipairs(client_keymaps) do
      map(km[1], km[2], km[4], km[3], bufnr)
    end
  end
end
