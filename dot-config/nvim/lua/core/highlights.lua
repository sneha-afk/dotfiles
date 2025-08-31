-- .config/nvim/lua/core/highlights.lua
-- Since 0.11.3, these highlights don't seem to stick when set in the plugin config

local function highlights()
  vim.api.nvim_set_hl(0, "DropBarIconUISeparator", { link = "Constant" })
  vim.api.nvim_set_hl(0, "DropBarMenuHoverEntry",  { link = "Search" })

  vim.api.nvim_set_hl(0, "MiniDiffSignAdd",        { link = "DiffAdd" })
  vim.api.nvim_set_hl(0, "MiniDiffSignChange",     { link = "DiffChange" })
  vim.api.nvim_set_hl(0, "MiniDiffSignDelete",     { link = "DiffDelete" })

  vim.api.nvim_set_hl(0, "MiniDiffOverAdd",        { link = "DiffAdd" })
  vim.api.nvim_set_hl(0, "MiniDiffOverChange",     { link = "DiffChange" })
  vim.api.nvim_set_hl(0, "MiniDiffOverChangeBuf",  { link = "Comment" })
  vim.api.nvim_set_hl(0, "MiniDiffOverContext",    { link = "Comment" })
  vim.api.nvim_set_hl(0, "MiniDiffOverContextBuf", { link = "Comment" })
  vim.api.nvim_set_hl(0, "MiniDiffOverDelete",     { link = "DiffDelete" })

  vim.api.nvim_set_hl(0, "MiniStarterHeader",      { link = "Define" })
  vim.api.nvim_set_hl(0, "MiniStarterFooter",      { link = "LineNr" })
  vim.api.nvim_set_hl(0, "MiniStarterQuery",       { link = "IncSearch" })
  vim.api.nvim_set_hl(0, "MiniStarterItemPrefix",  { link = "Keyword" })
  vim.api.nvim_set_hl(0, "MiniStarterItemBullet",  { link = "LineNr" })
  vim.api.nvim_set_hl(0, "MiniStarterCurrent",     { link = "CursorLine" })
  vim.api.nvim_set_hl(0, "MiniStarterSection",     { link = "Directory" })
end

vim.api.nvim_create_autocmd("UIEnter", {
  callback = function()
    vim.schedule(highlights)
  end,
})
