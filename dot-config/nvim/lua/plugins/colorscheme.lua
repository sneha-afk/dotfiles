-- .config/nvim/lua/plugins/colorscheme.lua

return {
  {
    "topazape/oldtale.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      styles = {
        comments = { italic = true },
        keywords = { bold = true },
        identifiers = {},
        functions = { bold = true },
        variables = {},
        booleans = { bold = true },
      },
      integrations = {
        blink = true,
        gitsigns = true,
        lazy = true,
        lsp = true,
        markdown = true,
        mason = true,
        notify = true,
        rainbow_delimiters = true,
        snacks = true,
        treesitter = true,
      },
    },
    config = function(_, opts)
      require("oldtale").setup(opts)
      vim.cmd.colorscheme("oldtale")
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
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
          text     = "#d8d9de",
          surface2 = "#34343e",
          surface1 = "#2b2b35",
          surface0 = "#23232d",
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
