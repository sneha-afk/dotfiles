-- ~/.config/nvim/lua/core/utils.lua
-- Module of utility functions and constants

local M = {}

---Touch a file, creating if it does not exist
---@param filepath string
---@return boolean True on success
function M.touch_file(filepath)
  local file = io.open(filepath, "a")
  if file then
    file:close()
    return true
  end
  return false
end

---Creates and returns the id of a new scratch buffer
---@param content? string[] Content to place into buffer
---@return integer ID of scratch buffer
function M.create_scratch_buf(content)
  local buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_set_option_value("buftype",   "nofile", { buf = buf })
  vim.api.nvim_set_option_value("bufhidden", "wipe",   { buf = buf })
  vim.api.nvim_set_option_value("swapfile",  false,    { buf = buf })
  if content then vim.api.nvim_buf_set_lines(buf, 0, -1, false, content) end
  return buf
end

---Returns centered width, height, columns, and rows for a floating window
---@return table Dimensions centered on screen
function M.get_centered_dims()
  local width = math.max(80, vim.o.columns - 20)
  local height = math.max(20, vim.o.lines - 15)
  local col = (vim.o.columns - width) / 2
  local row = (vim.o.lines - height) / 2
  return { width, height, col, row }
end

---@return boolean True if currently inside a Git repo
function M.is_git_repo()
  vim.fn.system("git rev-parse --is-inside-work-tree")
  return vim.v.shell_error == 0
end

---@return string Root of git repository (starting from CWD)
function M.get_git_root()
  local dot_git_path = vim.fn.finddir(".git", ".;")
  return vim.fn.fnamemodify(dot_git_path, ":h")
end

---Opens a buffer within a floating window
---@param buf integer ID of buffer
---@param title string Title of the window
---@param opts? table Options for the window
function M.open_float_win(buf, title, opts)
  local dims = M.get_centered_dims()
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
      title_pos = "center",
    }, opts or {})
  )
end

return M
