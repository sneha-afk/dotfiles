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

M.ignores = {
  static = {
    [".git"] = true,
    ["node_modules"] = true,
    ["__pycache__"] = true,
    [".DS_Store"] = true,
    ["package-lock.json"] = true,
    ["yarn.lock"] = true,
    ["Cargo.lock"] = true,
    ["pnpm-lock.yaml"] = true,
  },
  patterns = {
    "%.lock$", "%.tmp$", "%.bak$", "%.sw[po]$", "%.py[co]$",
    "^%..*%.swp$", "^[dD]ebug$", "^[rR]elease$", "^target$",
    "^dist$", "^build$", "^venv$", "^%.venv$", "^%.cache$",
    "^%.idea$", "^%.vscode$", "^%.history$",
  },
}

---Returns true if a file by `name` should be ignored
---@param name string
---@return boolean Ignore `name`?
function M.ignore(name)
  -- O(1) lookup -> fast path
  if M.ignores.static[name] then
    return true
  end

  -- Compile + cache regexes upon first call
  if not M.ignores.compiled then
    local compiled = {}
    for _, pattern in ipairs(M.ignores.patterns) do
      table.insert(compiled, { pattern = pattern, re = vim.regex(pattern) })
    end
    M.ignores.compiled = compiled
  end

  for _, item in ipairs(M.ignores.compiled) do
    if item.re:match_str(name) then return true end
  end

  return false
end

-- Flat list of file patterns to ignore
---@type table<string>
M.exclude_globs = vim.iter({ vim.tbl_keys(M.ignores.static), M.ignores.patterns }):flatten():totable()

return M
