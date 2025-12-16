-- .config/nvim/lsp/basedpyright.lua
-- basedpyright has a superset of settings from pyright.

---@type vim.lsp.Config
return {
  settings = {
    basedpyright = {
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
