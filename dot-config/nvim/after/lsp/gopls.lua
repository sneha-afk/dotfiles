-- .config/nvim/lsp/gopls.lua

---@type vim.lsp.Config
return {
  settings = {
    gopls = {
      directoryFilters = {
        "-**/node_modules",
        "-**/.git",
        "-**/vendor",
      },
      staticcheck = true,
      usePlaceholders = true,
      completeUnimported = true,
      semanticTokens = true,
      analyses = { -- See https://github.com/golang/tools/blob/master/gopls/doc/analyzers.md
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
    },
  },
}
