return {
  -- Colorscheme
  {
    "vague2k/vague.nvim",
    config = function()
      vim.cmd.colorscheme("vague")
    end
  },

  -- Status Line
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",
          icons_enabled = false,    -- Minimal look, only text
        },
        sections = {
          lualine_a = {'mode'},                      -- Left: Mode (Normal/Insert)
          lualine_b = {'filename', 'readonly'},      -- Left: Filename + RO flag
          lualine_c = {
            'branch',                                -- Git branch name
            'diff',                                  -- Git changes (+,~,-)
            'diagnostics'                            -- Optional: LSP errors/warnings
          },
          lualine_x = {'filetype'},                  -- Right: Filetype
          lualine_y = {'progress'},                  -- Right: Percentage
          lualine_z = {'location'}                   -- Right: Line:Column
        },
        -- Inactive windows: only show filename and location
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {'filename'},
          lualine_x = {'location'},
          lualine_y = {},
          lualine_z = {}
        }
      })
    end,
  }
}
