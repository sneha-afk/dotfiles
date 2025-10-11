-- .config/nvim/lua/core/utils/fileops.lua

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

---@return string|nil Git root path or nil if not inside a git repo
function M.get_git_root()
  local found = vim.fs.find(".git", {
    upward = true,
    path = vim.uv.cwd() or vim.fn.getcwd(),
    type = "directory",
  })

  if #found == 0 then return nil end
  return vim.fs.dirname(vim.fs.normalize(found[1]))
end

---@return string Root directory to start searching from, either a Git repo or CWD
function M.start_search_path()
  local cwd = vim.uv.cwd()
  if not cwd or cwd:match("ministarter") then cwd = vim.fn.getcwd() end

  -- Default to home if not in a directory
  if vim.fn.isdirectory(cwd) == 0 then
    return vim.fn.expand("~")
  end

  return M.get_git_root() or cwd
end

return M
