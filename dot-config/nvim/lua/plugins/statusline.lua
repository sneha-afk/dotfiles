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
      lualine_b = { "filename", },
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
          mode = 2,
          path = 1,
        }
      },
    },
  },
}
