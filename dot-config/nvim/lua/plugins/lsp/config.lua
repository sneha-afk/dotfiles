-- .config/nvim/plugins/lsp/config.lua
-- Global configurations applied to all LSPs

-- LSP-specific keymaps that should be attached once the client is known
local lsp_keymap_config = require("plugins.lsp.server_keymaps")

local disable_formatting = {
  ts_ls = true,
  tsserver = true,
}

vim.api.nvim_create_augroup("LspFormatting", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    local filetype = vim.bo[bufnr].filetype

    lsp_keymap_config(client)

    if disable_formatting[client.name] then
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
      client.server_capabilities.documentOnTypeFormattingProvider = false
    end

    -- From Neovim docs: prefer LSP folding if available
    if client:supports_method("textDocument/foldingRange") then
      vim.opt_local.foldmethod = "expr"
      vim.opt_local.foldexpr = "v:lua.vim.lsp.foldexpr()"
    end
  end,
})

-- Taken from https://neovim.io/doc/user/lsp.html#LspDetach
vim.api.nvim_create_autocmd("LspDetach", {
  callback = function(args)
    vim.api.nvim_clear_autocmds({
      group = "LspFormatting",
      event = "BufWritePre",
      buffer = args.buf,
    })
  end,
})

---Figures out which completion environment is being used to extend capabilities
---@return lsp.ClientCapabilities
local function get_capabilities_source()
  if pcall(require, "blink.cmp") then
    return require("blink.cmp").get_lsp_capabilities({}, false)
  elseif pcall(require, "cmp_nvim_lsp") then
    return require("cmp_nvim_lsp").default_capabilities()
  else
    return {}
  end
end

-- Return overrides of vim.lsp.ClientConfig
---@type vim.lsp.Config
return {
  capabilities = vim.tbl_deep_extend("force",
    vim.lsp.protocol.make_client_capabilities(),
    get_capabilities_source()
  ),
  root_markers = { ".git" },
  settings = {
    telemetry = { enable = false },
  },
}
