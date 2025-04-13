-- .config/nvim/lua/plugins/colorscheme.lua

return {
  {
    "thesimonho/kanagawa-paper.nvim",
    event = "UIEnter",
    priority = 1000,
    opts = {},
    config = function()
      vim.cmd.colorscheme("kanagawa-paper-ink")
    end,
  },
  {
    "AlexvZyl/nordic.nvim",
    lazy = true,
    opts = {},
  },
}
