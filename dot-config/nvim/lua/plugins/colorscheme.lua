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
          surface2 = "#37373f",
          surface1 = "#2e2e37",
          surface0 = "#25252e",
          base     = "#191920",
          mantle   = "#13131a",
          crust    = "#0e0e14",

          pink     = "#d7a8c4",
          mauve    = "#b8aed0",
          red      = "#da879a",
          peach    = "#e5b6a8",
          yellow   = "#d8cf9a",
          green    = "#afcdaa",
          teal     = "#95c6bc",
          sky      = "#a9cde0",
          sapphire = "#9ab5d0",
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
    opts = {
      bold_keywords = true,
      italic_comments = true,
      reduced_blue = true,
      swap_backgrounds = true,
      ts_context = { dark_background = false },
    },
    config = function(_, opts)
      require("nordic").setup(opts)
      vim.cmd.colorscheme("nordic")
    end,
  },
}
