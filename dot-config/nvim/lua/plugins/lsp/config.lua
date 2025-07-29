-- .config/nvim/plugins/lsp/config.lua
-- Global configurations applied to all LSPs

local format_config = {
  -- Toggle for auto-formatting on save (all LSPs)
  auto_format_on_save = false,

  --- Filetypes that should NEVER be formatted externally
  never_format_filetypes = {
    markdown = true,
  },

  -- Servers that bypass global toggle
  always_format_servers = {
    lua_ls = true,
    gopls = true,
  },

  -- Filetypes that bypass global toggle
  always_format_filetypes = {
    typescript = true,
    typescriptreact = true,
    javascript = true,
    javascriptreact = true,
    html = true,
    htmldjango = true,
    css = true,
    scss = true,
  },
}

-- LSP-specific keymaps that should be attached once the client is known
local lsp_keymap_config = require("plugins.lsp.server_keymaps")

vim.api.nvim_create_augroup("LspFormatting", { clear = true })
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    local filetype = vim.bo[bufnr].filetype

    lsp_keymap_config(client)

    local should_format = not format_config.never_format_filetypes[filetype]
        and (
          format_config.auto_format_on_save
          or (format_config.always_format_servers[client.name] and client:supports_method("textDocument/formatting", bufnr))
          or format_config.always_format_filetypes[filetype]
        )
    if should_format then
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = "LspFormatting",
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ async = false })
        end,
      })
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
