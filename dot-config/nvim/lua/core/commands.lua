-- .config/nvim/lua/core/commands.lua
-- Set user commands, autocommands, etc.

local buf_utils = require("utils.buffers_and_windows")
local file_utils = require("utils.fileops")

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

---Taken from LazyVim
---Create an autocommand group with the given name
---@param name string Group name
---@return integer AutocmdGroup id
local function augroup(name)
  return vim.api.nvim_create_augroup("Autocmds_" .. name, { clear = true })
end

-- ============================================================================
-- USER COMMANDS
-- ============================================================================

vim.api.nvim_create_user_command("VSCodeFile",   "!code -g %:p",     { nargs = 0, desc = "Open current file in VSCode" })
vim.api.nvim_create_user_command("IntelliJFile", "!idea %:p --line", { nargs = 0, desc = "Open current file in IntelliJ" })

vim.api.nvim_create_user_command("VSCodeRepo", function()
  local repo = file_utils.get_git_root()
  if repo then
    vim.fn.jobstart({ "code", repo }, { detach = true })
  else
    print("Not inside a git repository!")
  end
end, { desc = "Open Git repo root in VSCode" })

vim.api.nvim_create_user_command("IntelliJRepo", function()
  local repo = file_utils.get_git_root()
  if repo then
    vim.fn.jobstart({ "idea", repo }, { detach = true })
  else
    print("Not inside a git repository!")
  end
end, { desc = "Open Git repo root in IntelliJ" })

vim.api.nvim_create_user_command("EnvVariables", function()
  local env_vars = vim.fn.environ()
  local lines = { "# PATH VARIABLES", "" }
  local other_vars = {}

  -- Separate PATH-like variables from others
  for k, v in pairs(env_vars) do
    if k:match("PATH$") then
      table.insert(lines, string.format("## %s", k))

      if type(v) == "string" and v ~= "" then
        local separator = vim.fn.has("win32") == 1 and ";" or ":"
        for path in v:gmatch("[^" .. separator .. "]+") do
          if path ~= "" then table.insert(lines, string.format("  - %s", path)) end
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

  local buf = buf_utils.create_scratch_buf(lines)
  vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })
  vim.keymap.set("n", "<Esc>", "<cmd>q<cr>", { buffer = buf })
  local h = math.floor(vim.o.lines / 1.5)
  local r = (vim.o.lines - h) / 2
  buf_utils.open_float_win(buf, " Environment Variables ", {
    height = h,
    row = r,
  })
end, { desc = "View system environment variables" })

vim.api.nvim_create_user_command("CrToLf", function()
  if vim.bo.fileformat == "dos" or vim.fn.search("\r$", "nw") > 0 then
    local view = vim.fn.winsaveview()

    -- Save file, remove the trailing CR (^M), set fileformat to Unix, then write
    vim.cmd([[
      update
      silent! %s/\r$//e
      set fileformat=unix
      noautocmd write
    ]])

    vim.fn.winrestview(view)
    vim.notify("Converted CRLF to LF line endings", vim.log.levels.INFO)
  else
    vim.notify("No CRLF line endings found", vim.log.levels.INFO)
  end
end, { desc = "Change CRLF line endings to LF" })

-- https://www.npmjs.com/package/serve
vim.api.nvim_create_user_command("Serve", function()
  if vim.fn.executable("npx") ~= 1 then
    vim.notify(
      "`npx` not found. Please install Node.js (which includes npx).",
      vim.log.levels.ERROR,
      { title = "npx serve" }
    )
    return
  end

  vim.notify(
    "Starting server at http://localhost:3000",
    vim.log.levels.INFO,
    { title = "npx serve" }
  )

  vim.system(
    { "npx", "serve" },
    { detach = true },
    function() end
  )
end, {
  desc = "Start local static server using npx serve",
})

-- ============================================================================
-- AUTO COMMANDS
-- ============================================================================

vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("restore_cursor"),
  desc = "Restore cursor to last position when reopening file",
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      vim.cmd('normal! g`"zz')
    end
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("remove_whitespace"),
  desc = "Remove trailing whitespace and extra newlines at EOF upon saves",
  callback = function()
    local filetype = vim.bo.filetype
    local buftype = vim.bo.buftype

    -- Skip special buffers and certain filetypes
    if buftype ~= "" then return end
    local excluded_filetypes = {
      diff = true,
      gitcommit = true,
      text = true,
      markdown = true,
    }
    if excluded_filetypes[filetype] then return end

    local view = vim.fn.winsaveview()

    pcall(function()
      vim.cmd([[keeppatterns %s/\s\+$//e]])   -- Remove trailing whitespace
      vim.cmd([[silent! %s/\%(\n\+\%$\)//e]]) -- Remove extra newlines at EOF
    end)

    vim.fn.winrestview(view)
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("hl_yank"),
  desc = "Highlight yanked lines",
  callback = function() vim.hl.on_yank({ higroup = "Visual", timeout = 500 }) end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup("clear_lsp_logs"),
  desc = "Auto-clear LSP logs past 10 MB",
  callback = function()
    local log_path = vim.lsp.log.get_filename()
    local max_size = 10 * 1024 * 1024

    local ok, stats = pcall(vim.uv.fs_stat, log_path)
    if ok and stats and stats.size > max_size then
      local file = io.open(log_path, "w")
      if file then
        file:close()
        vim.notify("Cleared LSP log (>10MB)", vim.log.levels.INFO)
      end
    end
  end,
})

-- From LazyVim
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  desc = "Automatically create directories for a new file",
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then return end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})
