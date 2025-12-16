-- .config/nvim/lsp/pyright.lua

---@type vim.lsp.Config
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
