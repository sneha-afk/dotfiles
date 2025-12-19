-- .config/nvim/lua/plugins/ui.lua

return {
  {
    "nvim-mini/mini.icons",
    lazy = true,
    version = false,
    opts = {
      style = vim.g.use_icons and "glyph" or "ascii",
    },
    config = function(_, opts)
      local icons = require("mini.icons")
      icons.setup(opts)
      icons.mock_nvim_web_devicons()
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
