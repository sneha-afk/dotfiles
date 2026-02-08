-- .config/nvim/lua/plugins/statusline.lua

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = vim.g.use_icons and { "nvim-mini/mini.icons" } or {},
  opts = {
    options = {
      theme                = "auto",
      icons_enabled        = vim.g.use_icons,
      section_separators   = { left = "", right = "" },
      component_separators = { left = "│", right = "│" },
      disabled_filetypes   = {
        "starter",
        "ministarter",
        "help",
        "lazy",
        "mason",
        "leetcode.nvim",
        "snacks_picker_list",
        "snacks_dashboard",
      },
      always_show_tabline  = false,
    },
    refresh = {
      refresh_time = 32,
    },
    extensions = {
      "quickfix",
      "toggleterm",
      "overseer",
      "nvim-dap-ui",
      vim.g.enable_avante and "avante" or nil,
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
      lualine_c = { "branch", "diff",
        {
          "diagnostics",
          symbols = { error = "E:", warn = "W:", info = "I:", hint = "H:" },
        },
      },
      lualine_x = {
        {
          "lsp_status",
          icon = "",
          ignore_lsp = {},
        },
      },
      lualine_y = {
        "encoding",
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
        "progress",
      },
      lualine_z = { "location" },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {},
      lualine_x = {
        { "filename", path = 1 },
      },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
  },
  config = function(_, opts)
    require("lualine").setup(opts)
    vim.opt.showmode = false
  end,
}
