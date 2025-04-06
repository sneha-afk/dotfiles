-- .config/nvim/lua/plugins/lsp/server_configs.lua
-- List of all servers to use and specific configurations

-- Server name = { table of configurations }, or empty if using defaults
-- See: https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
return {
  bashls = {},

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
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME,
            vim.fn.stdpath("config"),
          },
        },
        format = {
          enable = true,
          defaultConfig = {
            indent_style = "space",
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
