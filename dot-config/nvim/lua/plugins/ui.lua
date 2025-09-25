-- .config/nvim/lua/plugins/ui.lua

return {
  -- Display diff signs in gutter
  {
    "echasnovski/mini.diff",
    version = false,
    event = "UIEnter",
    keys = {
      {
        "<leader>gd",
        function() require("mini.diff").toggle_overlay(0) end,
        desc = "[G]it: toggle [D]iff Overlay",
      },
    },
    opts = {
      view = {
        style = "sign",
        signs = { add = "┃", change = "┇", delete = "━" },
      },
    },
    config = true,
  },

  -- Rainbow brackets/delimiters for clarity
  {
    "HiPhish/rainbow-delimiters.nvim",
    lazy = false,
    ---@module "rainbow-delimiters"
    ---@type rainbow_delimiters.config
    opts = {
      query = {
        [""] = "rainbow-delimiters",
        lua = "rainbow-blocks",
        latex = "rainbow-blocks",
        javascript = "rainbow-delimiters-react",
        typescript = "rainbow-parens",
        tsx = "rainbow-tags-react",
        typescriptreact = "rainbow-tags-react",
      },
      priority = {
        [""] = 145,
        latex = 210,
        lua = 210,
      },
      -- Defines list of highlights to cycle through
      highlight = {
        "Statement",
        "Character",
        "Special",
        "Number",
        "Type",
        "Boolean",
      },
    },
    main = "rainbow-delimiters.setup",
  },
}
