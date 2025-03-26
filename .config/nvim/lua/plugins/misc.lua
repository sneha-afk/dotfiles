-- .config/nvim/lua/plugins/misc.lua
-- Miscellaneous plugins and smaller features

return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {},
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      indent = {
        enabled = true,
        animate = { enabled = false },
      },
      picker = { enabled = true },
      statuscolumn = { enabled = true },
    },
  },
}
