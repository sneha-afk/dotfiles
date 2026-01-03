-- .config/nvim/lua/core/keymaps.lua
-- Globally available keymaps

local buf_utils = require("utils.buffers_and_windows")

local map = vim.keymap.set
local lsp = vim.lsp
local diagnostic = vim.diagnostic

local float_ui = {
  border = "rounded",
  max_width = 120,
  title = " LSP Info ",
  title_pos = "center",
}

-- ============================================================================
-- EDITOR UTILITIES
-- ============================================================================
map("n", "<leader>cs", "<cmd>nohl<cr>",       { desc = "[C]lear [S]earch highlights" })
map("n", "<leader>un", "<cmd>set nu!<cr>",    { desc = "[U]I: toggle line [N]umbers" })
map("n", "<leader>ur", "<cmd>set rnu!<cr>",   { desc = "[U]I: toggle [R]elative line nums" })
map("n", "<leader>uw", "<cmd>set wrap!<cr>",  { desc = "[U]I: toggle line [W]rap" })
map("n", "<leader>us", "<cmd>set spell!<cr>", { desc = "[U]I: toggle [S]pell check" })
map("n", "<leader>uh", function() lsp.inlay_hint.enable(not lsp.inlay_hint.is_enabled()) end,
  { desc = "[U]I: toggle inlay [H]int" })

-- Scratch buffers
map("n", "<leader>sb", function() vim.api.nvim_set_current_buf(buf_utils.create_scratch_buf()) end,
  { desc = "[S]cratch: empty [B]uffer" })
map("n", "<leader>sm", function()
  local buf = buf_utils.create_scratch_buf(vim.split(vim.fn.execute("messages"), "\n"))
  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
  vim.keymap.set("n", "<Esc>", "<cmd>q<cr>", { buffer = buf })
  buf_utils.open_float_win(buf, " Messages ")
end, { desc = "[S]cratch: view [M]essages" })

-- Start local server (requires npx/serve)
map("n", "<leader>ss", function()
  vim.notify("Starting server at localhost:3000", vim.log.levels.INFO, { title = "npx serve" })
  local handle = io.popen("npx serve & 2>&1") -- https://www.npmjs.com/package/serve
end, { desc = "[S]tart live [s]erver" })

-- Taken from ThePrimeagen, changed to gc to default to confirmation
map("n", "<leader>sr", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gc<Left><Left><Left>]], {
  silent = false,
  desc = "[S]earch+[R]eplace word",
})

-- Visual mode search and replace selection
map("v", "<leader>sr", [["zy:%s/<C-r>z/<C-r>z/gc<Left><Left><Left>]], {
  silent = false,
  desc = "[S]earch+[R]eplace selection",
})

-- MOVING LINES, from LazyVim (A -> Alt)
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==",                   { desc = "Move Down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==",             { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi",                                   { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi",                                   { desc = "Move Up" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv",       { desc = "Move Down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- INDENTING, from LazyVim
map("v", "<", "<gv", { desc = "Decrease Indent" })
map("v", ">", ">gv", { desc = "Increase Indent" })

-- ============================================================================
-- NAVIGATION SHORTCUTS
-- ============================================================================
-- Moving around easier on QWERTY
map("n", "<C-a>", "^",       { desc = "Start of line (first non-blank)" })
map("n", "<C-e>", "$",       { desc = "End of line" })
map("i", "<C-a>", "<ESC>^i", { desc = "Start of line (first non-blank)" })
map("i", "<C-e>", "<ESC>$a", { desc = "End of line" })

-- ============================================================================
-- TERMINAL OPERATIONS
-- ============================================================================
map("n", "<leader>ht", "<cmd>split | term<cr>i",  { desc = "[H]orizontal [T]erminal" })
map("n", "<leader>vt", "<cmd>vsplit | term<cr>i", { desc = "[V]ertical [T]erminal" })
map("t", "<Esc>",      "<C-\\><C-n>",             { desc = "Exit terminal mode" })
map("t", "<C-w>h",     "<C-\\><C-n><C-w>h",       { desc = "Move left from terminal" })
map("t", "<C-w>j",     "<C-\\><C-n><C-w>j",       { desc = "Move down from terminal" })
map("t", "<C-w>k",     "<C-\\><C-n><C-w>k",       { desc = "Move up from terminal" })
map("t", "<C-w>l",     "<C-\\><C-n><C-w>l",       { desc = "Move right from terminal" })
map("t", "<C-w>q",     "<C-\\><C-n>:q<CR>",       { desc = "Close terminal" })
map("t", "<M-3>",      "<C-\\><C-n>:q<CR>",       { desc = "Close terminal" }) -- Alt/Meta + 3
map("t", "<C-j>",      "<C-\\><C-n><C-d>",        { desc = "Half page down" })
map("t", "<C-k>",      "<C-\\><C-n><C-u>",        { desc = "Half page up" })

-- ============================================================================
-- FILE OPERATIONS
-- ============================================================================
map("n", "<leader>w", "<cmd>w<cr>",  { desc = "Save file" })
map("n", "<leader>q", "<cmd>q<cr>",  { desc = "Quit window" })
map("n", "<leader>x", "<cmd>wq<cr>", { desc = "Save & quit" })
map("n", "<leader>Q", "<cmd>qa<cr>", { desc = "Quit all windows" })

-- ============================================================================
-- WINDOW MANAGEMENT
-- ============================================================================
map("n", "<C-h>",      "<C-w>h",          { desc = "Move to left window" })
map("n", "<C-j>",      "<C-w>j",          { desc = "Move to below window" })
map("n", "<C-k>",      "<C-w>k",          { desc = "Move to above window" })
map("n", "<C-l>",      "<C-w>l",          { desc = "Move to right window" })
map("n", "<leader>vs", "<cmd>vsplit<cr>", { desc = "[V]ertical [S]plit" })
map("n", "<leader>hs", "<cmd>split<cr>",  { desc = "[H]orizontal [S]plit" })

-- RESIZE ACTIONS, from LazyVim
map("n", "<C-Up>",    "<cmd>resize +2<cr>",          { desc = "Increase Window Height" })
map("n", "<C-Down>",  "<cmd>resize -2<cr>",          { desc = "Decrease Window Height" })
map("n", "<C-Left>",  "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- TOGGLING MAXIMIZATION
map("n", "<leader>um", "<C-w>_<C-w>|", { desc = "[U]I: [M]aximize window" })
map("n", "<leader>u=", "<C-w>=",       { desc = "[U]I: Balance windows" })


-- ============================================================================
-- BUFFER OPERATIONS
-- ============================================================================
map("n", "<leader>]b", "<cmd>bnext<cr>",   { desc = "Next buffer" })
map("n", "<leader>[b", "<cmd>bprev<cr>",   { desc = "Previous buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "[B]uffer: [D]elete current" })
map("n", "<leader>bD", "<cmd>bd!<cr>",     { desc = "[B]uffer: [D]elete current (force)" })
map("n", "<leader>bc", function()
  local current = vim.api.nvim_get_current_buf()
  local buffers = vim.api.nvim_list_bufs()
  local num_deleted = 0
  for _, buf in ipairs(buffers) do
    if buf ~= current and vim.api.nvim_buf_is_loaded(buf) then
      local buf_type = vim.api.nvim_get_option_value("buftype", { buf = buf })
      if buf_type == "" or buf_type == "help" then -- Only close normal/help buffers
        vim.api.nvim_buf_delete(buf, { force = true })
        num_deleted = num_deleted + 1
      end
    end
  end
  vim.notify("Deleted other open buffers (total: " .. num_deleted .. ")", vim.log.levels.INFO)
end, { desc = "[B]uffer: [C]lose all others" })

-- ============================================================================
-- TAB OPERATIONS
-- ============================================================================
map("n", "<leader>tn", "<cmd>tabnew<CR>",      { desc = "[T]ab: [N]ew" })
map("n", "<leader>tc", "<cmd>tabclose<CR>",    { desc = "[T]ab: [C]lose current" })
map("n", "<leader>to", "<cmd>tabonly<CR>",     { desc = "[T]ab: close all [O]thers" })
map("n", "<leader>]t", "<cmd>tabnext<CR>",     { desc = "Next tab" })
map("n", "<leader>[t", "<cmd>tabprevious<CR>", { desc = "Previous tab" })
map("n", "<leader>tm", "<cmd>tabmove<CR>",     { desc = "[T]ab: [M]ove current to last" })
map("n", "<leader>tl", "<cmd>tablast<CR>",     { desc = "[T]ab: goto [L]ast" })
for i = 1, 3 do
  map("n", "<leader>t" .. i, i .. "gt", { desc = "[T]ab: go to " .. i })
end

-- ============================================================================
-- QUICKFIX & LOCATION LIST
-- ============================================================================
map("n", "<leader>[q", "<cmd>cprev<cr>",  { desc = "Previous quickfix item" })
map("n", "<leader>]q", "<cmd>cnext<cr>",  { desc = "Next quickfix item" })
map("n", "<leader>qo", "<cmd>copen<cr>",  { desc = "[Q]uickfix: [O]pen" })
map("n", "<leader>qc", "<cmd>cclose<cr>", { desc = "[Q]uickfix: [C]lose" })

-- ============================================================================
-- DIAGNOSTICS
-- ============================================================================
map("n", "<leader>dt", function() diagnostic.enable(not diagnostic.is_enabled()) end, { desc = "[D]iagnostics: [T]oggle" })
map("n", "<leader>dl", diagnostic.open_float,                                         { desc = "[D]iagnostics: on this [L]ine" })
map("n", "<leader>df", diagnostic.setloclist,                                         { desc = "[D]iagnostics: [F]ile-local list" })
map("n", "<leader>da", function() diagnostic.setqflist({ open = true }) end,
  { desc = "[D]iagnostics: [A]ll project-wide" })
map("n", "<leader>[d", function() diagnostic.jump({ count = -1, float = true }) end, { desc = "Previous diagnostic" })
map("n", "<leader>]d", function() diagnostic.jump({ count = 1, float = true }) end,  { desc = "Next diagnostic" })
map("n", "<leader>dv",
  function() diagnostic.config({ virtual_text = not diagnostic.config().virtual_text }) end,
  { desc = "[D]iagnostics: toggle [V]irtual text" })

--  LSP NAVIGATION
-- map("n", "gd", lsp.buf.definition, { desc = "[G]oto [d]efinition" })
map("n", "gD", lsp.buf.declaration, { desc = "[G]oto [D]eclaration" })
-- map("n", "gi", lsp.buf.implementation, { desc = "[G]oto [I]mplementation" })
-- map("n", "gy", lsp.buf.type_definition, { desc = "[G]oto t[y]pe definition" })
map("n", "gY", lsp.buf.typehierarchy, { desc = "[G]oto t[Y]pe hierarchy" })
-- map("n", "gr", lsp.buf.references, { desc = "[G]oto [r]eferences" })
-- map("n", "gI", lsp.buf.incoming_calls, { desc = "[G]oto [I]ncoming calls" })
-- map("n", "gO", lsp.buf.outgoing_calls, { desc = "[G]oto [O]utgoing calls" })

-- ============================================================================
-- LSP ACTIONS
-- ============================================================================
--  DOCUMENTATION
map("n", "K",     function() lsp.buf.hover(float_ui) end,          { desc = "Open documentation float" })
map("i", "<C-k>", function() lsp.buf.signature_help(float_ui) end, { desc = "[S]ignature [H]elp" })

--  WORKSPACE
map("n", "<leader>Wa", lsp.buf.add_workspace_folder,    { desc = "[W]orkspace: [A]dd Folder" })
map("n", "<leader>Wr", lsp.buf.remove_workspace_folder, { desc = "[W]orkspace: [R]emove Folder" })
map("n", "<leader>Wl", function() vim.print(lsp.buf.list_workspace_folders()) end,
  { desc = "[W]orkspace: [L]ist Folders" })

--  CODE ACTIONS
map("n", "<leader>rn", lsp.buf.rename,                                  { desc = "[R]e[n]ame Symbol" })
map("n", "<leader>cl", lsp.codelens.run,                                { desc = "Run [C]ode[L]ens" })
map("n", "<leader>cf", function() lsp.buf.format({ async = true }) end, { desc = "[C]ode [F]ormat" })
map("n", "<leader>ca", lsp.buf.code_action,                             { desc = "[C]ode [A]ctions" })
map("v", "<leader>ca", function()
  lsp.buf.code_action({
    diagnostics = diagnostic.get(0),
    only = { "quickfix", "refactor", "source" },
  })
end, { desc = "Range [C]ode [A]ctions" })

--  SYMBOLS
map("n", "<leader>ls", lsp.buf.document_symbol,  { desc = "[L]SP: document [S]ymbols" })
map("n", "<leader>lS", lsp.buf.workspace_symbol, { desc = "[L]SP: workspace [S]ymbols" })
