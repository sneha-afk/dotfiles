-- .config/nvim/lua/plugins/lsp/server_configs.lua
-- Define any overrides from the default neovim-lspconfig, and map keymaps for each server

-- Custom configurations to override from default nvim-lspconfig
return {
  pyright = {
    settings = {
      pyright = {
        typeCheckingMode = "basic",
        useLibraryCodeForTypes = true,
      },
    },
  },

  gopls = {
    settings = {
      gopls = {
        staticcheck = true,
        usePlaceholders = true,
        completeUnimported = true,
        semanticTokens = true,
        analyses = {
          nilness = true,
          unusedwrite = true,
          unreachable = true,
          useany = true,
          unusedvariable = true,
          fillreturns = true,
        },
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          constantValues = true,
          functionTypeParameters = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },
        codelenses = {
          generate = true,
          gc_details = true,
          upgrade_dependency = true
        }
      },
    },
  },

  clangd = {
    cmd = { "clangd" },
    args = {
      "--clang-tidy",
      "--background-index",
      "--compile-commands-dir=build",
      "--header-insertion=never",
      "--all-scopes-completion",
      "--offset-encoding=utf-16",
    },
    init_options = {
      fallbackFlags = { "-std=c++11", "-Wall", "-Wextra", "-Wpedantic" },
    },
  },

  lua_ls = {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" }, },
        workspace = {
          library = {
            vim.env.VIMRUNTIME,
            vim.fn.stdpath("config"),
          },
        },
        format = {
          enable = true,
          defaultConfig = {
            quote_style = "double",
            align_call_args = true,
            space_around_assign = true,
            trailing_table_separator = "smart",
            insert_final_newline = false,
          },
        },
      },
    },
  },
}
