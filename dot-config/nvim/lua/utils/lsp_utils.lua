-- .config/nvim/lua/utils/lsp_utils.lua

local M = {}


---Figures out which completion environment is being used to extend capabilities
---@return lsp.ClientCapabilities
function M.get_capabilities_source()
  if pcall(require, "blink.cmp") then
    return require("blink.cmp").get_lsp_capabilities({}, true)
  elseif pcall(require, "cmp_nvim_lsp") then
    return require("cmp_nvim_lsp").default_capabilities()
  else
    return {}
  end
end

---@return lsp.ClientCapabilities
function M.get_full_capabilities()
  return vim.tbl_deep_extend("force",
    vim.lsp.protocol.make_client_capabilities(),
    M.get_capabilities_source()
  )
end

return M
