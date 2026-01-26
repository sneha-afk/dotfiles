-- .config/nvim/lsp/clangd.lua

---Find the nearest directory containing a compile_commands.json file
---@return string Path to directory containing compile_commands.json
local function find_compile_commands_dir()
  for _, dir in ipairs({ "build", "out", "compile_commands" }) do
    local path = dir .. "/compile_commands.json"
    if vim.uv.fs_stat(path) then
      return dir
    end
  end

  return "." -- fallback to project root
end

---@type vim.lsp.Config
return {
  cmd = {
    "clangd",
    "--background-index",
    "--pretty",
    "--clang-tidy",                -- Run clang-tidy diagnostics
    "--completion-style=detailed", -- Rich completion info
    "--header-insertion=iwyu",     -- Insert headers automatically
    "--function-arg-placeholders", -- Placeholders in snippets
    "--all-scopes-completion",     -- Complete across all visible scopes
    "--enable-config",             -- Read .clangd config if present
    "--pch-storage=memory",        -- Use memory for faster startup (good for SSD/RAM)
    "--compile-commands-dir=" .. find_compile_commands_dir(),
  },
  init_options = {
    fallbackFlags = { "-Wall", "-Wextra", "-Wpedantic" },
    usePlaceholders = true,
    completeUnimported = true,
    clangdFileStatus = true,
  },
}
