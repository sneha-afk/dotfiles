-- .config/nvim/lsp/pyright.lua

return {
  settings = {
    pyright = {
      disableOrganizeImports = false,
      analysis = {
        autoImportCompletions = true,
        autoSearchPaths = true,

        diagnosticSeverityOverrides = {
          reportUnknownArgumentType  = "none",
          reportUnknownLambdaType    = "none",
          reportUnknownMemberType    = "none",
          reportUnknownParameterType = "none",
          reportUnknownVariableType  = "none",
          reportMissingTypeStubs     = "info",
        },
      },
    },
  },
}
