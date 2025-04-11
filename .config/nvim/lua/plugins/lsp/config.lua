-- .config/nvim/plugins/lsp/config.lua
-- Global configurations applied to all LSPs

-- Toggle for auto-formatting on save (all LSPs)
local auto_format_on_save = false

-- Servers that will ignore the above setting
local always_format = {
  lua_ls = true,
  gopls = true,
}

-- Return overrides of vim.lsp.ClientConfig
return {
  -- Occurs on the LspAttach event
  on_attach = function(client, bufnr)
    require("plugins.lsp.keymaps")(client, bufnr)

    if (auto_format_on_save or always_format[client.name])
        and client.supports_method("textDocument/formatting") then
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        callback = function() vim.lsp.buf.format({ async = true }) end,
      })
    end

    vim.lsp.inlay_hint.enable()
  end,
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
  settings = {
    telemetry = { enable = false },
    completions = {
      completeFunctionCalls = true,
      triggerCompletionOnInsert = true,
    },
  },
}
