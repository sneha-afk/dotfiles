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

  -- Commenting
  {
    "numToStr/Comment.nvim",
    keys = {
      { "<leader>cc", desc = "Toggle line [c]omment" },
      { "<leader>bc", desc = "Toggle [b]lock [c]omment" },
      { "<leader>c",  desc = "Comment selection (linewise)",  mode = "v", },
      { "<leader>b",  desc = "Comment selection (blockwise)", mode = "v", },
    },
    opts = {
      padding = true, -- Adds space after comment symbol
      sticky = true,  -- Cursor stays in place
      toggler = {
        line = "<leader>cc",
        block = "<leader>bc",
      },
      opleader = {
        line = "<leader>c",
        block = "<leader>b",
      },
    },
  },
}
