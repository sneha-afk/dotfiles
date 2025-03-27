-- .config/nvim/lua/plugins/misc.lua
-- Miscellaneous plugins and smaller features

return {
  -- Git markers in the status column
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },

  -- Remove whitespace and blank lines at EOF on save
  {
    "mcauley-penney/tidy.nvim",
    event = "BufWritePre",
    opts = {
      filetype_exclude = { "markdown", "diff", },
      buftype_exclude = { "nofile", "terminal" },
    },
    config = true,
  },

  -- Snacks!
  {
    "folke/snacks.nvim",
    event = { "BufReadPre", "BufNewFile" },
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
