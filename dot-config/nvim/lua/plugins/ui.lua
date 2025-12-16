-- .config/nvim/lua/plugins/ui.lua

return {
  {
    "nvim-mini/mini.icons",
    enabled = vim.g.use_icons,
    version = false,
    lazy = true,
    opts = {
      style = "glyph",
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
    event = "VeryLazy",
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
    config = function(_, opts)
      require("mini.diff").setup(opts)

      local hl = vim.api.nvim_set_hl
      hl(0, "MiniDiffSignAdd",        { link = "DiffAdd" })
      hl(0, "MiniDiffSignChange",     { link = "DiffChange" })
      hl(0, "MiniDiffSignDelete",     { link = "DiffDelete" })

      hl(0, "MiniDiffOverAdd",        { link = "DiffAdd" })
      hl(0, "MiniDiffOverChange",     { link = "DiffChange" })
      hl(0, "MiniDiffOverChangeBuf",  { link = "Comment" })
      hl(0, "MiniDiffOverContext",    { link = "Comment" })
      hl(0, "MiniDiffOverContextBuf", { link = "Comment" })
      hl(0, "MiniDiffOverDelete",     { link = "DiffDelete" })
    end,
  },

  -- Rainbow brackets/delimiters for clarity
  {
    "HiPhish/rainbow-delimiters.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
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
      highlight = require("utils.ui").color_cycle,
    },
    main = "rainbow-delimiters.setup",
  },
}
