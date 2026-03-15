-- .config/nvim/lsp/ts_ls.lua
-- https://github.com/typescript-language-server/typescript-language-server/

local inlay_hints = {
  includeInlayParameterNameHints = "all",
  includeInlayParameterNameHintsWhenArgumentMatchesName = false,
  includeInlayFunctionParameterTypeHints = true,
  includeInlayVariableTypeHints = true,
  includeInlayVariableTypeHintsWhenTypeMatchesName = false,
  includeInlayPropertyDeclarationTypeHints = true,
  includeInlayFunctionLikeReturnTypeHints = false,
  includeInlayEnumMemberValueHints = true,
}

---@type vim.lsp.Config
return {
  init_options = {
    maxTsServerMemory = 4096,
    preferences = {
      includeCompletionsForModuleExports = true,
      includeCompletionsForImportStatements = true,
      includePackageJsonAutoImports = "auto",
    },
  },
  ---@module "lspconfig"
  ---@type lspconfig.settings.ts_ls
  settings = {
    diagnostics = {
      -- https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json
      ---@type number[]
      ignoredCodes = {},
    },
    typescript = {
      inlayHints = inlay_hints,
    },
    javascript = {
      inlayHints = inlay_hints,
    },
  },
  single_file_support = true,
}
