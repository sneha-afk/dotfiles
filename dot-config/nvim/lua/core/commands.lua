-- .config/nvim/lua/core/commands.lua
-- Set user commands, autocommands, etc.

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

vim.api.nvim_create_user_command("VSCodeFile", "!code -g %:p", { nargs = 0, desc = "Open current file in VSCode" })
vim.api.nvim_create_user_command("IntelliJFile", "!idea %:p --line",
  { nargs = 0, desc = "Open current file in IntelliJ" })

vim.api.nvim_create_user_command("VSCodeRepo", function()
  local repo = require("utils.paths").get_git_root()
  if repo then
    vim.fn.jobstart({ "code", repo }, { detach = true })
  else
    vim.notify("Not inside a git repository!", vim.log.levels.WARN)
  end
end, { desc = "Open Git repo root in VSCode" })

vim.api.nvim_create_user_command("IntelliJRepo", function()
  local repo = require("utils.paths").get_git_root()
  if repo then
    vim.fn.jobstart({ "idea", repo }, { detach = true })
  else
    vim.notify("Not inside a git repository!", vim.log.levels.WARN)
  end
end, { desc = "Open Git repo root in IntelliJ" })

vim.api.nvim_create_user_command("EnvVariables", function()
  local buf_utils = require("utils.buffers_and_windows")
  local env_vars = vim.fn.environ()
  local separator = vim.g.is_windows and ";" or ":"

  local lines = { "# PATH VARIABLES", "" }
  local other_vars = {}

  -- Separate PATH-like variables from others
  for k, v in pairs(env_vars) do
    if k:match("PATH$") then
      table.insert(lines, ("## %s"):format(k))

      if type(v) == "string" and v ~= "" then
        for path in v:gmatch("[^" .. separator .. "]+") do
          table.insert(lines, "  - " .. path)
        end
      else
        table.insert(lines, "  (empty)")
      end

      table.insert(lines, "")
    else
      table.insert(other_vars, ("% -20s = %s"):format(k, v))
    end
  end

  table.insert(lines, "# ENV VARIABLES")
  vim.list_extend(lines, other_vars)

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
    vim.cmd([[silent! %s/\r$//e]])
    vim.bo.fileformat = "unix"
    vim.cmd.write()

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

  vim.fn.jobstart({ "npx", "serve" }, { detach = true })
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

local strip_excluded_filetypes = {
  diff = true,
  gitcommit = true,
  text = true,
  markdown = true,
}

vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("remove_whitespace"),
  desc = "Remove trailing whitespace and extra newlines at EOF upon saves",
  callback = function()
    if vim.b.no_strip_whitespace then return end

    local filetype = vim.bo.filetype
    local buftype = vim.bo.buftype

    -- Skip special buffers and certain filetypes
    if buftype ~= "" then return end
    if strip_excluded_filetypes[filetype] then return end

    local view = vim.fn.winsaveview()

    vim.cmd([[keeppatterns %s/\s\+$//e]])      -- Remove trailing whitespace
    vim.cmd([[silent! %s#\($\n\s*\)\+\%$##e]]) -- Leave exactly one newline at EOF

    vim.fn.winrestview(view)
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("hl_yank"),
  desc = "Highlight yanked lines",
  callback = function() vim.hl.on_yank({ higroup = "Visual", timeout = 500 }) end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup("clear_lsp_logs"),
  desc = "Auto-clear LSP logs past 10 MB",
  callback = function()
    local log_path = vim.lsp.log.get_filename()
    local max_size = 10 * 1024 * 1024

    local stats = vim.uv.fs_stat(log_path)
    if stats and stats.size > max_size then
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
