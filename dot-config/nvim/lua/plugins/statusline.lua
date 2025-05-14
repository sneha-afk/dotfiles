-- .config/nvim/lua/plugins/statusline.lua

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = {
    options = {
      theme = "auto",
      icons_enabled = false,
      disabled_filetypes = {
        "starter", "ministarter", "help", "lazy", "mason",
      },
      always_show_tabline = false,
    },
    -- A, B, C are left; X, Y, Z are right
    sections = {
      lualine_b = {
        {
          "filename",
          path = 4, -- Parent directory + current file
        },
      },
      lualine_c = { "branch", "diff", "diagnostics", },
      lualine_x = {
        {
          "lsp_status",
          icon = "",
          ignore_lsp = {},
        },
        "filetype"
      },
    },
    -- Inactive windows default: only show filename and location
    tabline = {
      lualine_a = {
        {
          "tabs",
          tab_max_length = 60,
          max_length = vim.o.columns / 1.5,
          mode = 2, -- Tab number and name
          path = 1, -- Relative path
        }
      },
    },
  },
  config = function(_, opts)
    require("lualine").setup(opts)
    vim.opt.showmode = false
  end
}
