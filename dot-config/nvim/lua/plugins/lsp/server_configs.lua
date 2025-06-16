-- .config/nvim/lua/plugins/lsp/server_configs.lua

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
        generate = true,
        gc_details = true,
        upgrade_dependency = true,
      },
    },
  },
})

vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--all-scopes-completion",
    "--background-index",
    "--clang-tidy",
    "--compile-commands-dir=build",
    "--completion-style=detailed",
    "--cross-file-rename",
    "--enable-config",
    "--function-arg-placeholders",
    "--header-insertion=never",
    "--malloc-trim",
    "--offset-encoding=utf-16",
    "--pch-storage=disk",
  },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  init_options = {
    fallbackFlags = { "-Wall", "-Wextra", "-Wpedantic" },
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
