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
          surface2 = "#32323a",
          surface1 = "#292931",
          surface0 = "#22222a",
          base     = "#1b1b23",
          mantle   = "#15151c",
          crust    = "#0f0f16",

          pink     = "#d2a0b7",
          mauve    = "#a6a2b3",
          red      = "#d37a8a",
          peach    = "#e1ae95",
          yellow   = "#d2c77f",
          green    = "#a4c394",
          teal     = "#8dc0b1",
          sky      = "#a3c7d1",
          sapphire = "#90acbd",
          blue     = "#7592a9",
          lavender = "#9993c4",
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
