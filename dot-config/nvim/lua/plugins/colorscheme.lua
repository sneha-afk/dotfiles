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
          text     = "#c9c9cc",
          surface2 = "#36363f",
          surface1 = "#2b2b34",
          surface0 = "#23232b",
          base     = "#1a1a22",
          mantle   = "#15151c",
          crust    = "#101016",

          pink     = "#caa3b4",
          mauve    = "#b6b3c0",
          red      = "#cb7683",
          peach    = "#d7a98f",
          yellow   = "#c9c084",
          green    = "#9ab38d",
          teal     = "#87b0a5",
          sky      = "#9ab8c2",
          sapphire = "#88a1b0",
          blue     = "#6d879e",
          lavender = "#8e8ab6",
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
