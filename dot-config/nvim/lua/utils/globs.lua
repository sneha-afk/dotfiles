-- .config/nvim/lua/utils/globs.lua

local M = {}

local static_ignores = { -- O(1)
  [".git"] = true,
  [".gitmodules"] = true,
  [".svn"] = true,
  [".hg"] = true,
  ["CVS"] = true,

  [".cache"] = true,
  [".direnv"] = true,
  [".envrc"] = true,
  [".DS_Store"] = true,
  ["Thumbs.db"] = true,
  [".history"] = true,

  ["bazel-bin"] = true,
  ["bazel-out"] = true,
  ["bazel-testlogs"] = true,
  ["bazel-external"] = true,
  ["bazel-cache"] = true,

  [".gradle"] = true,
  ["target"] = true,
  ["build"] = true,
  ["out"] = true,
  [".classpath"] = true,
  [".project"] = true,
  [".factorypath"] = true,
  [".mvn"] = true,

  ["node_modules"] = true,
  [".next"] = true,
  [".prettierd"] = true,
  [".webpack"] = true,

  ["__pycache__"] = true,
  [".pytest_cache"] = true,
  [".mypy_cache"] = true,
  [".ruff_cache"] = true,
  [".tox"] = true,
  [".venv"] = true,
  ["venv"] = true,
  ["pip-wheel-metadata"] = true,
  ["htmlcov"] = true,
  [".ipynb_checkpoints"] = true,

  ["tmp"] = true,
  [".bundle"] = true,

  [".cargo"] = true,

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
  ".o", ".obj", ".class", ".pyc", ".pyo", ".pyd",
  ".so", ".dll", ".dylib", ".lib", ".exe", ".a",
  ".gch", ".pch", ".iml", ".ipr", ".iws", ".rbc",
  ".jar", ".war", ".ear", ".d.ts.map",
}

local pattern_ignores = {
  "%.swp%d+$", "%.bak%d+$",
  "%.min%.js$", "%.min%.css$", "%.bundle%.js$", "%.bundle%.css$",
}

local exclude_globs = vim.tbl_keys(static_ignores)
for i = 1, #suffix_ignores do
  exclude_globs[#exclude_globs + 1] = "*" .. suffix_ignores[i]
end

---Returns true if a file by `name` should be ignored
---@param name string
---@param bufnr? integer optional buffer number (oil passes this, others don't)
---@return boolean Ignore `name`?
function M.ignore(name, bufnr)
  -- Oil provides bufnr and passes in basename only
  -- Else, check for path separators to handle both cases
  local is_basename = bufnr ~= nil or not name:find("/", 1, true)

  if not is_basename then
    -- fast dir short-circuit
    if name:find("node_modules/", 1, true)
    or name:find(".git/", 1, true)
    or name:find("bazel-", 1, true)
    or name:find("target/", 1, true)
    or name:find("dist/", 1, true)
    or name:find("build/", 1, true)
    or name:find("__pycache__/", 1, true)
    or name:find(".venv/", 1, true)
    or name:find("venv/", 1, true)
    then
      return true
    end
  end

  local basename = is_basename and name or (name:match("[^/]+$") or name)

  if static_ignores[basename] then return true end

  for i = 1, #suffix_ignores do
    local ext = suffix_ignores[i]
    if basename:sub(- #ext) == ext then
      return true
    end
  end

  for i = 1, #pattern_ignores do
    if basename:find(pattern_ignores[i]) then
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
