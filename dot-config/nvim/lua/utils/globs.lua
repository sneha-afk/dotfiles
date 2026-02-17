-- .config/nvim/lua/utils/globs.lua

local M = {}

local static_ignores = { -- O(1)
  [".git"] = true,
  [".gitmodules"] = true,
  [".svn"] = true,
  [".hg"] = true,
  ["CVS"] = true,

  ["node_modules"] = true,
  ["vendor"] = true,
  [".bundle"] = true,
  ["venv"] = true,
  [".venv"] = true,

  ["__pycache__"] = true,
  [".pytest_cache"] = true,
  [".mypy_cache"] = true,
  [".ruff_cache"] = true,
  [".tox"] = true,

  ["dist"] = true,
  ["build"] = true,
  ["out"] = true,
  ["target"] = true,
  [".next"] = true,

  [".cache"] = true,
  [".turbo"] = true,
  [".parcel-cache"] = true,
  [".webpack"] = true,

  ["package-lock.json"] = true,
  ["yarn.lock"] = true,
  ["pnpm-lock.yaml"] = true,
  ["Cargo.lock"] = true,
  ["Gemfile.lock"] = true,
  ["go.sum"] = true,
  ["poetry.lock"] = true,
}

local suffix_ignores = { -- O(n), no regex
  ".tmp", ".bak", ".orig", ".rej", "~", ".swp", ".swo", ".swn",
  ".o", ".obj", ".class", ".pyc", ".pyo", ".so", ".dll", ".dylib", ".exe", ".a",
  ".gch", ".pch",
  ".jar", ".war", ".ear",
}

local pattern_ignores = {
  "%.swp%d+$", "%.bak%d+$",
  "%.min%.js$", "%.min%.css$", "%.bundle%.js$", "%.bundle%.css$",
}

local exclude_globs = vim.tbl_keys(static_ignores)
vim.list_extend(exclude_globs, vim.tbl_map(function(ext) return "*" .. ext end, suffix_ignores))

---Returns true if a file by `name` should be ignored
---@param name string
---@return boolean Ignore `name`?
function M.ignore(name)
  if static_ignores[name] then return true end

  for i = 1, #suffix_ignores do
    if vim.endswith(name, suffix_ignores[i]) then
      return true
    end
  end

  for i = 1, #pattern_ignores do
    if name:find(pattern_ignores[i]) then
      return true
    end
  end

  return false
end

-- Flat list of file patterns to ignore
---@return string[]
function M.get_exclude_globs()
  return exclude_globs
end

return M
