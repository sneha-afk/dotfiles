-- ~/.config/nvim/lua/core/filetypes.lua
-- Filetype-specific settings

local M = {}

-- Define groups of settings that can be mapped to multiple filetypes
local filetype_groups = {
  -- Tab-indented files
  no_expand_tab = {
    ft = { "make", "go", "terraform" },
    opts = {
      expandtab = false,
      tabstop = 4,
      softtabstop = 4,
      shiftwidth = 4,
    },
  },

  spell_files = {
    ft = { "markdown", "tex", "gitcommit" },
    opts = {
      spell = true,
      wrap = true,
    },
  },

  c_indent = {
    ft = { "c", "cpp", "h", "hpp" },
    opts = {
      cindent = true,
    },
  },

  smaller_tabs = {
    ft = { "lua", },
    opts = {
      tabstop = 2,
      softtabstop = 2,
      shiftwidth = 2,
    }
  }
}

function M.setup()
  for group, config in pairs(filetype_groups) do
    vim.api.nvim_create_autocmd("FileType", {
      pattern = config.ft,
      callback = function()
        for opt, value in pairs(config.opts) do
          vim.opt_local[opt] = value
        end
      end,
      group = vim.api.nvim_create_augroup("FileType_" .. group, { clear = true }),
    })
  end
end

return M
