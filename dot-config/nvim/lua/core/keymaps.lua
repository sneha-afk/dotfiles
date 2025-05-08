-- .config/nvim/lua/core/keymaps.lua
-- Globally available keymaps

local utils = require("core.utils")
local map = utils.set_keymap

local lsp = vim.lsp
local diagnostic = vim.diagnostic


local float_ui = {
  border = "rounded",
  max_width = 120,
  title = " LSP Info ",
  title_pos = "center",
}

---Opens a buffer within a floating window
---@param buf integer ID of buffer
---@param title string Title of the window
---@param opts? table Options for the window
local function open_float_win(buf, title, opts)
  local dims = utils.get_centered_dims()
  vim.api.nvim_open_win(buf, true,
    vim.tbl_extend("force", {
      relative = "editor",
      width = dims[1],
      height = dims[2],
      col = dims[3],
      row = dims[4],
      style = "minimal",
      border = "rounded",
      title = title,
      title_pos = "center"
    }, opts or {})
  )
end

--  UTILITIES
map("n", "<leader>cs", "<cmd>nohl<cr>", { desc = "[C]lear [S]earch highlights" })
map("n", "<leader>un", "<cmd>set nu!<cr>", { desc = "[U]I: toggle line [N]umbers" })
map("n", "<leader>ur", "<cmd>set rnu!<cr>", { desc = "[U]I: toggle [R]elative line nums" })
map("n", "<leader>uw", "<cmd>set wrap!<cr>", { desc = "[U]I: toggle line [W]rap" })
map("n", "<leader>us", "<cmd>set spell!<cr>", { desc = "[U]I: toggle [S]pell check" })
map("n", "<leader>uh", function() lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end,
  { desc = "[U]I: toggle inlay [H]int" })
map("n", "<leader>sb", function() vim.api.nvim_set_current_buf(utils.create_scratch_buf()) end,
  { desc = "[S]cratch: empty [B]uffer" })
map("n", "<leader>sm", function()
  -- Get messages and split into lines
  local buf = utils.create_scratch_buf(vim.split(vim.fn.execute("messages"), "\n"))

  vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
  open_float_win(buf, " Messages ")
end, { desc = "[S]cratch: view [M]essages" })
map("n", "<leader>se", function()
  local env_vars = vim.fn.environ()
  local lines = { "# PATH VARIABLES", "" }
  local other_vars = {}

  for k, v in pairs(env_vars) do
    if k:match("PATH$") then
      table.insert(lines, string.format("## %s", k))

      if type(v) == "string" and v ~= "" then
        local separator = vim.fn.has("win32") == 1 and ";" or ":"
        for path in v:gmatch("[^" .. separator .. "]+") do
          if path ~= "" then
            table.insert(lines, string.format("  - %s", path))
          end
        end
      else
        table.insert(lines, "  (empty)")
      end
      table.insert(lines, "")
    else
      table.insert(other_vars, string.format("%-20s = %s", k, v))
    end
  end

  table.insert(lines, "# ENV VARIABLES")
  for _, v in ipairs(other_vars) do
    table.insert(lines, v)
  end

  local buf = utils.create_scratch_buf(lines)
  vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })
  local h = math.floor(vim.o.lines / 1.5)
  local r = (vim.o.lines - h) / 2
  open_float_win(buf, " Environment Variables ", {
    height = h,
    row = r,
  })
end, { desc = "[S]cratch: [E]nvironment Variables" })

--  TERMINAL OPERATIONS
map("n", "<leader>ht", "<cmd>split | term<cr>i", { desc = "[H]orizontal [T]erminal" })
map("n", "<leader>vt", "<cmd>vsplit | term<cr>i", { desc = "[V]ertical [T]erminal" })
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
map("t", "<C-w>h", "<C-\\><C-n><C-w>h", { desc = "Move left from terminal" })
map("t", "<C-w>j", "<C-\\><C-n><C-w>j", { desc = "Move down from terminal" })
map("t", "<C-w>k", "<C-\\><C-n><C-w>k", { desc = "Move up from terminal" })
map("t", "<C-w>l", "<C-\\><C-n><C-w>l", { desc = "Move right from terminal" })
map("t", "<C-w>q", "<C-\\><C-n>:q<CR>", { desc = "Close terminal" })
map("t", "<C-j>", "<C-\\><C-n><C-d>", { desc = "Half page down" })
map("t", "<C-k>", "<C-\\><C-n><C-u>", { desc = "Half page up" })

--  FILE OPERATIONS
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit window" })
map("n", "<leader>x", "<cmd>wq<cr>", { desc = "Save & quit" })
map("n", "<leader>Q", "<cmd>qa<cr>", { desc = "Quit all windows" })

--  WINDOW MANAGEMENT
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to below window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to above window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
map("n", "<leader>vs", "<cmd>vsplit<cr>", { desc = "[V]ertical [S]plit" })
map("n", "<leader>hs", "<cmd>split<cr>", { desc = "[H]orizontal [S]plit" })

--  BUFFER OPERATIONS
map("n", "<leader>]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>[b", "<cmd>bprev<cr>", { desc = "Previous buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "[B]uffer: [D]elete current" })
map("n", "<leader>bD", "<cmd>bd!<cr>", { desc = "[B]uffer: [D]elete current (force)" })
map("n", "<leader>bc", function()
  local current = vim.api.nvim_get_current_buf()
  local buffers = vim.api.nvim_list_bufs()

  for _, buf in ipairs(buffers) do
    if buf ~= current and vim.api.nvim_buf_is_loaded(buf) then
      local buf_type = vim.api.nvim_get_option_value("buftype", { buf = buf })
      if buf_type == "" or buf_type == "help" then -- Only close normal/help buffers
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end
  end
  vim.notify("Deleted other buffers", vim.log.levels.INFO)
end, { desc = "[B]uffer: [C]lose all others" })

--  TAB OPERATIONS
map("n", "<leader>tn", "<cmd>tabnew<CR>", { desc = "[T]ab: [N]ew" })
map("n", "<leader>tc", "<cmd>tabclose<CR>", { desc = "[T]ab: [C]lose current" })
map("n", "<leader>to", "<cmd>tabonly<CR>", { desc = "[T]ab: close all [O]thers" })
map("n", "<leader>]t", "<cmd>tabnext<CR>", { desc = "Next tab" })
map("n", "<leader>[t", "<cmd>tabprevious<CR>", { desc = "Previous tab" })
map("n", "<leader>tm", "<cmd>tabmove<CR>", { desc = "[T]ab: [M]ove current to last" })
map("n", "<leader>tl", "<cmd>tablast<CR>", { desc = "[T]ab: jump to [L]ast open" })
map("n", "<leader>t1", "1gt", { desc = "[T]ab: go to [1]" })
map("n", "<leader>t2", "2gt", { desc = "[T]ab: go to [2]" })
map("n", "<leader>t3", "3gt", { desc = "[T]ab: go to [3]" })
map("n", "<leader>t4", "4gt", { desc = "[T]ab: go to [4]" })

--  DIAGNOSTICS
map("n", "<leader>dt", function() diagnostic.enable(not diagnostic.is_enabled()) end,
  { desc = "[D]iagnostics: [T]oggle" })
map("n", "<leader>dl", diagnostic.open_float, { desc = "[D]iagnostics: open [L]ist" })
map("n", "<leader>df", diagnostic.setloclist, { desc = "[D]iagnostics: [F]ile-local list" })
map("n", "<leader>da", function() diagnostic.setqflist({ open = true }) end,
  { desc = "[D]iagnostics: [A]ll project-wide" })
map("n", "<leader>[d", function() diagnostic.jump { count = -1, float = true } end, { desc = "Previous diagnostic" })
map("n", "<leader>]d", function() diagnostic.jump { count = 1, float = true } end, { desc = "Next diagnostic" })
map("n", "<leader>dv", function() diagnostic.config({ virtual_text = not diagnostic.config().virtual_text }) end,
  { desc = "[D]iagnostics: toggle [V]irtual text" })

--  LSP NAVIGATION
map("n", "gd", lsp.buf.definition, { desc = "[G]oto [d]efinition" })
map("n", "gD", lsp.buf.declaration, { desc = "[G]oto [D]eclaration" })
map("n", "gi", lsp.buf.implementation, { desc = "[G]oto [I]mplementation" })
map("n", "gy", lsp.buf.type_definition, { desc = "[G]oto t[y]pe definition" })
map("n", "gr", lsp.buf.references, { desc = "[G]oto [r]eferences" })
map("n", "gI", lsp.buf.incoming_calls, { desc = "[G]oto [I]ncoming calls" })
map("n", "gO", lsp.buf.outgoing_calls, { desc = "[G]oto [O]utgoing calls" })

--  DOCUMENTATION
map("n", "K", function() lsp.buf.hover(float_ui) end, { desc = "Open documentation float" })
map("i", "<C-k>", function() lsp.buf.signature_help(float_ui) end, { desc = "[S]ignature [H]elp" })

--  WORKSPACE
map("n", "<leader>wa", lsp.buf.add_workspace_folder, { desc = "[W]orkspace [A]dd Folder" })
map("n", "<leader>wr", lsp.buf.remove_workspace_folder, { desc = "[W]orkspace [R]emove Folder" })
map("n", "<leader>wl", function() vim.print(lsp.buf.list_workspace_folders()) end,
  { desc = "[W]orkspace [L]ist Folders" })

--  CODE ACTIONS
map("n", "<leader>rn", lsp.buf.rename, { desc = "[R]e[n]ame Symbol" })
map("n", "<leader>cl", lsp.codelens.run, { desc = "Run [C]ode[L]ens" })
map("n", "<leader>cf", function() lsp.buf.format({ async = true }) end, { desc = "[C]ode [F]ormat" })
map("n", "<leader>ca", lsp.buf.code_action, { desc = "[C]ode [A]ctions" })
map("v", "<leader>ca", function()
  lsp.buf.code_action({
    diagnostics = diagnostic.get(0),
    only = { "quickfix", "refactor", "source" }
  })
end, { desc = "Range [C]ode [A]ctions" })

--  SYMBOLS
map("n", "<leader>ds", lsp.buf.document_symbol, { desc = "[D]ocument [S]ymbols" })
map("n", "<leader>ws", lsp.buf.workspace_symbol, { desc = "[W]orkspace [S]ymbols" })

-- MOVE ACTIONS, from LazyVim (A -> Alt)
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- RESIZE ACTIONS, from LazyVim
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- INDENTING, from LazyVim
map("v", "<", "<gv", { desc = "Decrease Indent" })
map("v", ">", ">gv", { desc = "Increase Indent" })
