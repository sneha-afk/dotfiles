-- .config/nvim/lua/plugins/editor.lua
-- Plugins for enhancing the direct editing experience: auto-pairing, comments

return {
  -- Auto-pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true
  },

  -- Remove whitespace and blank lines at EOF on save
  {
    "mcauley-penney/tidy.nvim",
    event = "BufWritePre",
    opts = {
      filetype_exclude = { "markdown", "diff", "gitcommit", },
      buftype_exclude  = { "nofile", "terminal", "prompt", },
    },
  },
}
