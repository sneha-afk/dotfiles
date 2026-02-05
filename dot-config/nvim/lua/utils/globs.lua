-- .config/nvim/lua/utils/globs.lua

local M = {}

local exclude_globs

M.ignores = {
  static = {
    [".git"] = true,
    [".gitmodules"] = true,

    ["node_modules"] = true,
    ["vendor"] = true,
    [".bundle"] = true,

    ["__pycache__"] = true,
    [".pytest_cache"] = true,
    [".mypy_cache"] = true,
    [".ruff_cache"] = true,
    ["venv"] = true,
    [".venv"] = true,

    [".DS_Store"] = true,

    ["package-lock.json"] = true,
    ["yarn.lock"] = true,
    ["pnpm-lock.yaml"] = true,
    ["Cargo.lock"] = true,
    ["Gemfile.lock"] = true,
    ["go.sum"] = true,
  },

  patterns = {
    "%.tmp$", "%.bak$", "%.swp$", "%.swo$", "~$",
    "%.o$", "%.obj$", "%.class$", "%.pyc$", "%.pyo$",
    "%.so$", "%.dll$", "%.dylib$", "%.exe$", "%.a$",
    "%.jar$", "%.war$", "%.ear$",
    "%.gch$", "%.pch$",

    "^%.cache$",
    "^%.pytest_cache$",
    "^%.mypy_cache$",
    "^%.ruff_cache$",
    "^%.tox$",
    "^__pycache__$",
  },
}

---Returns true if a file by `name` should be ignored
---@param name string
---@return boolean Ignore `name`?
function M.ignore(name)
  -- O(1) lookup -> fast path
  if M.ignores.static[name] then return true end

  -- O(n) lookup -> using match on each
  for i = 1, #M.ignores.patterns do
    if name:match(M.ignores.patterns[i]) then return true end
  end

  return false
end

-- Flat list of file patterns to ignore
---@return string[]
function M.get_exclude_globs()
  if not exclude_globs then
    exclude_globs = vim.list_extend(
      vim.tbl_keys(M.ignores.static),
      vim.deepcopy(M.ignores.patterns)
    )
  end
  return exclude_globs
end

return M
