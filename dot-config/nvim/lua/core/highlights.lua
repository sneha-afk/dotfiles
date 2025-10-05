-- .config/nvim/lua/core/highlights.lua
-- Since 0.11.3, these highlights don't seem to stick when set in the plugin config

local function set_highlights()
  local hl = vim.api.nvim_set_hl

  hl(0, "DropBarIconUISeparator", { link = "Constant" })
  hl(0, "DropBarMenuHoverEntry",  { link = "Search" })

  hl(0, "MiniDiffSignAdd",        { link = "DiffAdd" })
  hl(0, "MiniDiffSignChange",     { link = "DiffChange" })
  hl(0, "MiniDiffSignDelete",     { link = "DiffDelete" })

  hl(0, "MiniDiffOverAdd",        { link = "DiffAdd" })
  hl(0, "MiniDiffOverChange",     { link = "DiffChange" })
  hl(0, "MiniDiffOverChangeBuf",  { link = "Comment" })
  hl(0, "MiniDiffOverContext",    { link = "Comment" })
  hl(0, "MiniDiffOverContextBuf", { link = "Comment" })
  hl(0, "MiniDiffOverDelete",     { link = "DiffDelete" })

  hl(0, "MiniStarterHeader",      { link = "Define" })
  hl(0, "MiniStarterFooter",      { link = "LineNr" })
  hl(0, "MiniStarterQuery",       { link = "IncSearch" })
  hl(0, "MiniStarterItemPrefix",  { link = "Keyword" })
  hl(0, "MiniStarterItemBullet",  { link = "LineNr" })
  hl(0, "MiniStarterCurrent",     { link = "CursorLine" })
  hl(0, "MiniStarterSection",     { link = "Directory" })
end

vim.api.nvim_create_autocmd({ "ColorScheme", "UIEnter" }, {
  group = vim.api.nvim_create_augroup("UserCustomHighlights", { clear = true }),
  callback = function()
    vim.schedule(set_highlights)
  end,
})
