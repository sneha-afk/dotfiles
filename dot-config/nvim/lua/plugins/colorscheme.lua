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
          text     = "#d8d9de",
          surface2 = "#2f2f37",
          surface1 = "#262630",
          surface0 = "#202028",
          base     = "#181820",
          mantle   = "#12121a",
          crust    = "#0d0d14",

          pink     = "#d49eb9",
          mauve    = "#a9a0b6",
          red      = "#d6778c",
          peach    = "#e4ab97",
          yellow   = "#d5c581",
          green    = "#a7c196",
          teal     = "#90beb3",
          sky      = "#a6c5d3",
          sapphire = "#93aabf",
          blue     = "#788fa9",
          lavender = "#9c91c7",
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
    enabled = false,
    priority = 1000,
    config = function()
      local nordic = require("nordic")
      nordic.setup({
        bold_keywords = true,
        italic_comments = true,
        reduced_blue = true,
        swap_backgrounds = true,
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
