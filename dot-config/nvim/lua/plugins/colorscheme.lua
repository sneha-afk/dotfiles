-- .config/nvim/lua/plugins/colorscheme.lua

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    build = ":CatppuccinCompile",
    ---@type CatppuccinOptions
    opts = {
      auto_integrations = true,
      dim_inactive = {
        enabled = true,
      },
      styles = {
        functions = { "bold" },
        keywords = { "bold" },
        booleans = { "bold" },
        types = { "bold" },
        operators = {},
      },
      background = {
        dark = "mocha",
        light = "latte",
      },
      color_overrides = {
        mocha = {
          text     = "#d9dae1",
          surface2 = "#3a3a45",
          surface1 = "#31313b",
          surface0 = "#282832",
          base     = "#1b1b24",
          mantle   = "#15151e",
          crust    = "#101017",

          pink     = "#d7a8be",
          mauve    = "#b8aec9",
          red      = "#da879a",
          peach    = "#e5b6a4",
          yellow   = "#d8cf96",
          green    = "#afcdaa",
          teal     = "#95c6bc",
          sky      = "#a9cde0",
          sapphire = "#98b3cf",
          blue     = "#859bbd",
          lavender = "#aca3dd",
        },
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },
  {
    "AlexvZyl/nordic.nvim",
    lazy = true,
    priority = 1000,
    config = function()
      local nordic = require("nordic")
      nordic.setup({
        bold_keywords = true,
        italic_comments = true,
        reduced_blue = true,
        swap_backgrounds = true,
        ts_context = { dark_background = false },
        on_highlight = function(highlights, palette)
          -- Distinguish cursorline from Visual
          highlights.Visual = {
            bg = palette.gray1,
          }
        end,
      })
      vim.cmd.colorscheme("nordic")
    end,
  },
}
