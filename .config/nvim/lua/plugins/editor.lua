-- .config/nvim/lua/plugins/editor.lua
-- Plugins for enhancing the direct editing experience: auto-pairing, comments

return {
  -- Auto-pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      enable_check_bracket_line = false,
      ignored_next_char = "[%w%.]", -- Don't pair after letters/numbers
    },
  },

  -- Commenting
  {
    "numToStr/Comment.nvim",
    keys = {
      { "<leader>cc", desc = "Toggle line comment" },
      { "<leader>bc", desc = "Toggle block comment" },
      { "<leader>c", mode = "v", desc = "Comment selection (linewise)" },
      { "<leader>b", mode = "v", desc = "Comment selection (blockwise)" },
    },
    opts = {
      padding = true, -- Adds space after comment symbol
      sticky = true, -- Cursor stays in place
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
