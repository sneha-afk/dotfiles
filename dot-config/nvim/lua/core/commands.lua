-- .config/nvim/lua/core/commands.lua

---Create an autocommand group with the given name
---@param name string Group name
---@return integer AutocmdGroup id
local function augroup(name)
  return vim.api.nvim_create_augroup("Autocmds_" .. name, { clear = true })
end

-- ============================================================================
-- TERMINAL
-- ============================================================================

vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup("terminal_cmds"),
  callback = function()
    local opt = vim.opt_local
    opt.number = false         -- Disable line numbers
    opt.relativenumber = false -- Disable relative numbers
    opt.signcolumn = "no"      -- Hide sign column
    opt.cursorline = false     -- Disable current line highlight
    opt.buflisted = false      -- Exclude from buffer list
    opt.swapfile = false       -- No swap files for terminals
    opt.bufhidden = "hide"     -- Hide instead of unload when not visible
    opt.scrollback = 10000     -- Increase scrollback history
  end,
  desc = "Setup terminal buffer options and keymaps",
})

vim.api.nvim_create_autocmd("TermEnter", {
  group = augroup("terminal_cmds"),
  callback = function() vim.cmd("startinsert") end,
  desc = "Auto-enter insert mode when focusing terminal",
})

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
  local sep = vim.g.is_windows and ";" or ":"
  local env = vim.fn.environ()
  local keys = vim.tbl_keys(env)
  table.sort(keys)

  local user_lines = { "# USER VARIABLES", "" }
  local system_lines = { "", "# SYSTEM VARIABLES", "" }

  local function is_sensitive(name)
    name = name:lower()
    return name:find("api", 1, true)
        or name:find("key", 1, true)
        or name:find("token", 1, true)
        or name:find("secret", 1, true)
        or name:find("pass", 1, true)
  end

  local function mask_value(value)
    if not value or value == "" then return "" end
    return ("*"):rep(math.min(#value, 12)) .. " (hidden)"
  end

  for _, k in ipairs(keys) do
    local v = env[k] or ""
    if is_sensitive(k) then v = mask_value(v) end

    if k:match("PATH$") or k:match("DIRS$") then
      table.insert(user_lines, "## " .. k)
      for path in v:gmatch("[^" .. sep .. "]+") do
        table.insert(user_lines, "  - " .. path)
      end
      table.insert(user_lines, "")
    else
      table.insert(system_lines, ("%-25s │ %s"):format(k, v))
    end
  end

  vim.list_extend(user_lines, system_lines)

  local buf_utils = require("utils.buffers_and_windows")
  local buf = buf_utils.create_scratch_buf(user_lines, "markdown", false)
  buf_utils.open_float_win(buf, "Environment Variables")
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

  vim.fn.jobstart({ "npx", "serve", ".", "-l", "3000" }, { detach = true })
end, { desc = "Start local static server using npx serve" })

vim.api.nvim_create_user_command("CopyFilePath", function()
  -- Command: :let @+ = expand('%:p')
  local filepath = vim.fn.expand("%:p")
  vim.fn.setreg("+", filepath)
  vim.notify("Copied current (absolute) filepath to clipboard", vim.log.levels.INFO)
end, { desc = "Copies current file path to clipboard" })

-- thanks https://jdhao.github.io/2026/04/02/nvim-v012-release/
vim.api.nvim_create_user_command("LspLog", function(_)
  local log_path = vim.fs.joinpath(vim.fn.stdpath("state"), "lsp.log")
  vim.cmd(string.format("edit %s", log_path))
end, { desc = "Show LSP log" })

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
  desc = "Auto-clear LSP logs past a size",
  callback = function()
    local log_path = vim.lsp.log.get_filename()
    local max_size = 25 * 1024 * 1024

    local stats = vim.uv.fs_stat(log_path)
    if stats and stats.size > max_size then
      local file = io.open(log_path, "w")
      if file then
        file:close()
        vim.notify("Cleared LSP log (>25MB)", vim.log.levels.INFO)
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
