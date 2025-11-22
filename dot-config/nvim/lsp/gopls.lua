-- .config/nvim/lsp/gopls.lua

return {
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
}
