-- .config/nvim/lua/lsp/lsp_server_configs.lua

-- To use the default configurations supplied by nvim-lspconfig, simply add to
--    the vim.lsp.enable table in lsp/init.lua
-- See: https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
-- Set up server-specific overrides within this file.

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      hint = {
        enable = true,
      },
      workspace = {
        library = {
          vim.env.VIMRUNTIME,
        },
      },
      runtime = {
        version = "LuaJIT",
      },
      format = {
        enable = true,
        defaultConfig = {
          indent_style = "space",
          indent_size = "2",
          continuation_indent_size = "2",
          quote_style = "double",
          align_call_args = true,
          space_around_assign = true,
          trailing_table_separator = "smart",
          insert_final_newline = false,
        },
      },
    },
  },
})

vim.lsp.config("gopls", {
  settings = {
    gopls = {
      staticcheck = true,
      usePlaceholders = true,
      completeUnimported = true,
      semanticTokens = true,
      analyses = { -- See https://github.com/golang/tools/blob/master/gopls/doc/analyzers.md
        nilness = true,
        unusedwrite = true,
        unreachable = true,
        unusedvariable = true,
        fillreturns = true,
        QF1007 = true,
        S1002 = true,
        S1011 = true,
        S1016 = true,
        S1021 = true,
      },
      hints = { -- See https://github.com/golang/tools/blob/master/gopls/doc/inlayHints.md
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
      codelenses = {
        gc_details = false,
        generate = true,
        regenerate_cgo = true,
        run_govulncheck = true,
        test = true,
        tidy = true,
        upgrade_dependency = true,
        vendor = true,
      },
    },
  },
})

-- Detect nearest build directory with compile_commands.json
local function find_compile_commands_dir()
  local dirs = { "build", "out", "compile_commands" }
  for _, dir in ipairs(dirs) do
    if vim.fn.filereadable(dir .. "/compile_commands.json") == 1 then
      return dir
    end
  end
  return "."
end

vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--background-index",
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
})

vim.lsp.config("pyright", {
  settings = {
    pyright = {
      typeCheckingMode = "basic",
      disableOrganizeImports = false,
      analysis = {
        autoImportCompletions = true,
        autoSearchPaths = true,
        diagnosticMode = "workspace",
        useLibraryCodeForTypes = true,
      },
    },
  },
})

-- https://github.com/typescript-language-server/typescript-language-server/
vim.lsp.config("ts_ls", { -- tsserver
  init_options = {
    preferences = {
      includeInlayParameterNameHints = "all",
      includeInlayParameterNameHintsWhenArgumentMatchesName = true,
      includeInlayFunctionParameterTypeHints = true,
      includeInlayVariableTypeHints = true,
      includeInlayVariableTypeHintsWhenTypeMatchesName = true,
      includeInlayPropertyDeclarationTypeHints = true,
      includeInlayFunctionLikeReturnTypeHints = true,
      includeInlayEnumMemberValueHints = true,
    },
  },
})
