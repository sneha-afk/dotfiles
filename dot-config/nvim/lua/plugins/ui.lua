-- .config/nvim/lua/plugins/ui.lua

return {
  {
    "nvim-mini/mini.icons",
    enabled = vim.g.use_icons,
    version = false,
    lazy = true,
    opts = {
      style = require("core.utils.ui").icons_supported() and "glyph" or "ascii",
    },
    config = function(_, opts)
      local icons = require("mini.icons")
      icons.setup(opts)
      icons.mock_nvim_web_devicons()
    end,
  },
  -- Display diff signs in gutter
  {
    "nvim-mini/mini.diff",
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
    event = { "BufReadPost", "BufNewFile" },
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
      highlight = require("core.utils.ui").color_cycle,
    },
    main = "rainbow-delimiters.setup",
  },
}
