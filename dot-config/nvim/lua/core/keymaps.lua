-- .config/nvim/lua/core/keymaps.lua
-- Globally available keymaps

local lsp = vim.lsp
local diagnostic = vim.diagnostic

---@param mode string|string[]     -- Mode: e.g. "n", "i", or {"n", "v"}
---@param lhs string               -- Key combination (e.g. "<leader>f")
---@param action string|fun():nil|fun(...):any      -- Function, string command, or Lua expression
---@param desc string              -- Description for which-key
local function map(mode, lhs, action, desc)
  vim.keymap.set(mode, lhs, action, { desc = desc, noremap = true, silent = true })
end

local float_ui = {
  border = "rounded",
  max_width = 120,
  title = " LSP Info ",
  title_pos = "center",
}

--  UTILITIES
map("n", "<leader>cs", "<cmd>nohl<cr>", "[C]lear [S]earch highlights")
map("n", "<leader>un", "<cmd>set nu!<cr>", "[U]I: toggle line [N]umbers")
map("n", "<leader>ur", "<cmd>set rnu!<cr>", "[U]I: toggle [R]elative line nums")
map("n", "<leader>uw", "<cmd>set wrap!<cr>", "[U]I: toggle line [W]rap")
map("n", "<leader>uh", function() lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end,
  "[U]I: toggle inlay [H]int")

--  TERMINAL OPERATIONS
map("n", "<leader>ht", "<cmd>split | term<cr>i", "[H]orizontal [T]erminal")
map("n", "<leader>vt", "<cmd>vsplit | term<cr>i", "[V]ertical [T]erminal")
map("t", "<Esc>", "<C-\\><C-n>", "Exit terminal mode")
map("t", "<C-w>h", "<C-\\><C-n><C-w>h", "Move left from terminal")
map("t", "<C-w>j", "<C-\\><C-n><C-w>j", "Move down from terminal")
map("t", "<C-w>k", "<C-\\><C-n><C-w>k", "Move up from terminal")
map("t", "<C-w>l", "<C-\\><C-n><C-w>l", "Move right from terminal")
map("t", "<C-w>q", "<C-\\><C-n>:q<CR>", "Close terminal")
map("t", "<C-j>", "<C-\\><C-n><C-d>", "Half page down")
map("t", "<C-k>", "<C-\\><C-n><C-u>", "Half page up")

--  FILE OPERATIONS
map("n", "<leader>w", "<cmd>w<cr>", "Save file")
map("n", "<leader>q", "<cmd>q<cr>", "Quit window")
map("n", "<leader>x", "<cmd>wq<cr>", "Save & quit")
map("n", "<leader>Q", "<cmd>qa<cr>", "Quit all windows")

--  WINDOW MANAGEMENT
map("n", "<C-h>", "<C-w>h", "Move to left window")
map("n", "<C-j>", "<C-w>j", "Move to below window")
map("n", "<C-k>", "<C-w>k", "Move to above window")
map("n", "<C-l>", "<C-w>l", "Move to right window")
map("n", "<leader>vs", "<cmd>vsplit<cr>", "[V]ertical [S]plit")
map("n", "<leader>hs", "<cmd>split<cr>", "[H]orizontal [S]plit")

--  BUFFER OPERATIONS
map("n", "<leader>]b", "<cmd>bnext<cr>", "Go to next buffer")
map("n", "<leader>[b", "<cmd>bprev<cr>", "Go to previous buffer")
map("n", "<leader>bd", "<cmd>bdelete<cr>", "[B]uffer [D]elete")
map("n", "<leader>bD", "<cmd>bd!<cr>", "[B]uffer [D]elete (force)")

--  TAB OPERATIONS
map("n", "<leader>tn", "<cmd>tabnew<CR>", "[T]ab: [N]ew")
map("n", "<leader>tc", "<cmd>tabclose<CR>", "[T]ab: [C]lose current")
map("n", "<leader>to", "<cmd>tabonly<CR>", "[T]ab: close all [O]thers")
map("n", "<leader>]t", "<cmd>tabnext<CR>", "Go to next tab")
map("n", "<leader>[t", "<cmd>tabprevious<CR>", "Go to previous tab")
map("n", "<leader>tm", "<cmd>tabmove<CR>", "[T]ab: [M]ove current to last")
map("n", "<leader>tl", "<cmd>tablast<CR>", "[T]ab: jump to [L]ast open")
map("n", "<leader>t1", "1gt", "[T]ab: go to [1]")
map("n", "<leader>t2", "2gt", "[T]ab: go to [2]")
map("n", "<leader>t3", "3gt", "[T]ab: go to [3]")
map("n", "<leader>t4", "4gt", "[T]ab: go to [4]")

--  DIAGNOSTICS
map("n", "<leader>dt", function() diagnostic.enable(not diagnostic.is_enabled()) end, "[D]iagnostics: [T]oggle")
map("n", "<leader>dl", diagnostic.open_float, "[D]iagnostics: open [L]ist")
map("n", "<leader>df", diagnostic.setloclist, "[D]iagnostics: [F]ile-local list")
map("n", "<leader>da", function() diagnostic.setqflist({ open = true }) end, "[D]iagnostics: [A]ll project-wide")
map("n", "[d", function() diagnostic.jump { count = -1, float = true } end, "Previous diagnostic")
map("n", "]d", function() diagnostic.jump { count = 1, float = true } end, "Next diagnostic")
map("n", "<leader>dv", function() diagnostic.config({ virtual_text = not diagnostic.config().virtual_text }) end,
  "[D]iagnostics: toggle [V]irtual text")

--  LSP NAVIGATION
map("n", "gd", lsp.buf.definition, "[G]oto [d]efinition")
map("n", "gD", lsp.buf.declaration, "[G]oto [D]eclaration")
map("n", "gi", lsp.buf.implementation, "[G]oto [I]mplementation")
map("n", "gy", lsp.buf.type_definition, "[G]oto t[y]pe definition")
map("n", "gr", lsp.buf.references, "[G]oto [r]eferences")
map("n", "gI", lsp.buf.incoming_calls, "[G]oto [I]ncoming calls")
map("n", "gO", lsp.buf.outgoing_calls, "[G]oto [O]utgoing calls")

--  DOCUMENTATION
map("n", "K", function() lsp.buf.hover(float_ui) end, "Open documentation float")
map({ "n", "i" }, "<C-k>", function() lsp.buf.signature_help(float_ui) end, "[S]ignature [H]elp")

--  WORKSPACE
map("n", "<leader>wa", lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
map("n", "<leader>wr", lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
map("n", "<leader>wl", function() vim.print(lsp.buf.list_workspace_folders()) end, "[W]orkspace [L]ist Folders")

--  CODE ACTIONS
map("n", "<leader>rn", lsp.buf.rename, "[R]e[n]ame Symbol")
map("n", "<leader>cl", lsp.codelens.run, "Run [C]ode[L]ens")
map("n", "<leader>cf", lsp.buf.format, "[C]ode [F]ormat")
map("n", "<leader>ca", lsp.buf.code_action, "[C]ode [A]ctions")
map("v", "<leader>ca", function()
  lsp.buf.code_action({
    diagnostics = diagnostic.get(0),
    only = { "quickfix", "refactor", "source" }
  })
end, "Range [C]ode [A]ctions")

--  SYMBOLS
map("n", "<leader>ds", lsp.buf.document_symbol, "[D]ocument [S]ymbols")
map("n", "<leader>ws", lsp.buf.workspace_symbol, "[W]orkspace [S]ymbols")

--  LSP MANAGEMENT
map("n", "<leader>li", "<cmd>LspInfo<cr>", "[L]SP [I]nfo")
map("n", "<leader>lr", "<cmd>LspRestart<cr>", "[L]SP [R]estart")
