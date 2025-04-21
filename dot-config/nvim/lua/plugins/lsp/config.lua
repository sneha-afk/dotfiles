-- .config/nvim/plugins/lsp/config.lua
-- Global configurations applied to all LSPs

-- Toggle for auto-formatting on save (all LSPs)
local auto_format_on_save = false

-- Servers that will ignore the above setting
local always_format = {
  lua_ls = true,
  gopls = true,
}

-- LSP-specific keymaps that should be attached once the client is known
local lsp_keymap_config = require("plugins.lsp.server_keymaps")

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

    lsp_keymap_config(client)

    if (auto_format_on_save or always_format[client.name])
        and client:supports_method("textDocument/formatting", bufnr) then
      vim.api.nvim_create_autocmd("BufWritePre", {
        buffer = bufnr,
        callback = function() vim.lsp.buf.format({ async = true }) end,
      })
    end
  end
})

-- Taken from https://neovim.io/doc/user/lsp.html#LspDetach
vim.api.nvim_create_autocmd('LspDetach', {
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    -- Remove the autocommand to format the buffer on save, if it exists
    if client:supports_method('textDocument/formatting') then
      vim.api.nvim_clear_autocmds({
        event = 'BufWritePre',
        buffer = args.buf,
      })
    end
  end,
})

-- Return overrides of vim.lsp.ClientConfig
---@type vim.lsp.Config
return {
  capabilities = require("cmp_nvim_lsp").default_capabilities(),
  root_markers = { ".git" },
  settings = {
    telemetry = { enable = false },
    completions = {
      completeFunctionCalls = true,
      triggerCompletionOnInsert = true,
    },
  },
}
