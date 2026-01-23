-- .config/nvim/lua/utils/paths.lua

local M = {}

local cache = {
  cwd = nil,
  git_root = nil,
  start_path = nil,
}

local function invalidate_cache()
  cache.cwd = nil
  cache.git_root = nil
  cache.start_path = nil
end

---@return string|nil Git root path or nil if not inside a git repo
function M.get_git_root()
  local cwd = vim.uv.cwd() or vim.fn.getcwd()

  if cache.cwd ~= cwd then invalidate_cache() end
  if cache.git_root then return cache.git_root end

  local found = vim.fs.find(".git", {
    upward = true,
    path = cwd,
    type = "directory",
  })

  if #found > 0 then
    cache.git_root = vim.fs.dirname(found[1])
  end

  return cache.git_root
end

---@return string Root directory to start searching from, either a Git repo or CWD
function M.start_search_path()
  local cwd = vim.uv.cwd()
  if not cwd or cwd:find("ministarter", 1, true) then
    cwd = vim.fn.getcwd()
  end

  if cache.cwd ~= cwd then invalidate_cache() end
  if cache.start_path then return cache.start_path end

  -- Default to home if not in a directory
  if vim.fn.isdirectory(cwd) == 0 then
    cache.start_path = vim.fn.expand("~")
    return cache.start_path
  end

  cache.start_path = M.get_git_root() or cwd
  return cache.start_path
end

return M
