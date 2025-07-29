-- .config/nvim/lua/plugins/statusline.lua

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = {
    options = {
      theme = "auto",
      icons_enabled = false,
      disabled_filetypes = {
        "starter",
        "ministarter",
        "help",
        "lazy",
        "mason",
        "oil",
      },
      always_show_tabline = false,
    },
    -- A, B, C are left; X, Y, Z are right
    sections = {
      lualine_a = { "mode" },
      lualine_b = {
        {
          "filename",
          path = 4, -- Parent directory + current file
        },
      },
      lualine_c = { "branch", "diff", "diagnostics" },
      lualine_x = {
        {
          "lsp_status",
          ignore_lsp = {},
        },
      },
      lualine_y = {
        {
          "fileformat",
          icons_enabled = true,
          symbols = {
            unix = "LF",
            dos = "CRLF",
            mac = "LF",
          },
        },
        "filetype",
      },
      lualine_z = { "progress", "location" },
    },
    -- Inactive windows default: only show filename and location
    tabline = {
      lualine_a = {
        {
          "tabs",
          tab_max_length = 60,
          max_length = vim.o.columns,
          mode = 2, -- Tab number and name
          path = 1, -- Relative path
        },
      },
    },
  },
  init = function()
    vim.opt.showmode = false
  end,
}
