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
          text     = "#d7d8de",
          surface2 = "#363640",
          surface1 = "#2d2d37",
          surface0 = "#25252f",
          base     = "#191922",
          mantle   = "#13131c",
          crust    = "#0e0e15",

          pink     = "#d2a0b8",
          mauve    = "#b0a6c3",
          red      = "#d47a8e",
          peach    = "#e0ad9b",
          yellow   = "#d2c88a",
          green    = "#a9c6a1",
          teal     = "#8fbfb5",
          sky      = "#a3c6d8",
          sapphire = "#91abc6",
          blue     = "#7c92b3",
          lavender = "#a59bd6",
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
