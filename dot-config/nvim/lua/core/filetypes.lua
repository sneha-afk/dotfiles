-- ~/.config/nvim/lua/core/filetypes.lua
-- Filetype-specific settings

-- Define groups of settings that can be mapped to multiple filetypes
local no_expand_tab = { expandtab = false, tabstop = 4, softtabstop = 4, shiftwidth = 4 }
local spell_wrap    = { spell = true, wrap = true }
local c_indent      = { cindent = true }
local small_tabs    = { tabstop = 2, softtabstop = 2, shiftwidth = 2 }

local ft_opts       = {
  make      = no_expand_tab,
  go        = no_expand_tab,
  terraform = no_expand_tab,

  text      = spell_wrap,
  tex       = spell_wrap,
  plaintex  = spell_wrap,
  typst     = spell_wrap,
  gitcommit = spell_wrap,
  markdown  = spell_wrap,

  c         = c_indent,
  cpp       = c_indent,
  h         = c_indent,
  hpp       = c_indent,

  lua       = small_tabs,
  json      = small_tabs,
  html      = small_tabs,
  css       = small_tabs,
}

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("FiletypeLocalOpts", { clear = true }),
  pattern = "*",
  callback = function(ev)
    local opts = ft_opts[ev.match]
    if opts then
      for opt, val in pairs(opts) do
        vim.opt_local[opt] = val
      end
    end
  end,
})
