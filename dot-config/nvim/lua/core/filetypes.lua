-- ~/.config/nvim/lua/core/filetypes.lua
-- Filetype-specific settings

-- Define groups of settings that can be mapped to multiple filetypes
local profiles = {
  tabs_2 = {
    tabstop = 2,
    softtabstop = 2,
    shiftwidth = 2,
    expandtab = true,
  },

  tabs_4 = {
    tabstop = 4,
    softtabstop = 4,
    shiftwidth = 4,
    expandtab = true,
  },

  tabs_4_noexpand = {
    tabstop = 4,
    softtabstop = 4,
    shiftwidth = 4,
    expandtab = false,
  },

  spell_wrap = {
    spell = true,
    wrap = true,
  },

  c_indent = {
    cindent = true,
  },
}

local ft_profiles = {
  make       = { "tabs_4_noexpand" },
  go         = { "tabs_4_noexpand" },
  terraform  = { "tabs_4_noexpand" },

  text       = { "spell_wrap" },
  tex        = { "spell_wrap" },
  plaintex   = { "spell_wrap" },
  typst      = { "spell_wrap" },
  gitcommit  = { "spell_wrap" },
  markdown   = { "spell_wrap" },

  c          = { "tabs_4", "c_indent" },
  cpp        = { "tabs_4", "c_indent" },
  h          = { "tabs_4", "c_indent" },
  hpp        = { "tabs_4", "c_indent" },

  python     = { "tabs_4" },
  rust       = { "tabs_4" },
  zig        = { "tabs_4" },
  sh         = { "tabs_4" },
  bash       = { "tabs_4" },

  lua        = { "tabs_2" },
  json       = { "tabs_2" },
  yaml       = { "tabs_2" },
  toml       = { "tabs_2" },
  html       = { "tabs_2" },
  css        = { "tabs_2" },
  scss       = { "tabs_2" },
  javascript = { "tabs_2" },
  typescript = { "tabs_2" },
  jsx        = { "tabs_2" },
  tsx        = { "tabs_2" },
}

local ft_cache = {}

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("FiletypeLocalOpts", { clear = true }),
  pattern = vim.tbl_keys(ft_profiles),
  callback = function(ev)
    local ft = ev.match

    if ft_cache[ft] == nil then
      local profile_names = ft_profiles[ft]

      -- No options to apply
      if not profile_names then
        ft_cache[ft] = false
        return
      end

      local merged = {}
      for _, profile_name in ipairs(profile_names) do
        for opt, val in pairs(profiles[profile_name]) do
          merged[opt] = val
        end
      end
      ft_cache[ft] = merged
    end

    if not ft_cache[ft] then return end

    for opt, val in pairs(ft_cache[ft]) do vim.opt_local[opt] = val end
  end,
})
