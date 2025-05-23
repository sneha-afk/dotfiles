-- .config/nvim/lua/plugins/colorscheme.lua

return {
  {
    "webhooked/kanso.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    config = function()
      vim.cmd.colorscheme("kanso-ink")
    end,
  },
  {
    "comfysage/aki",
    lazy = true,
    priority = 1000,
    opts = {
      contrast_dark = "hard",
      override_terminal = true,
    },
    config = function(_, opts)
      require("aki").setup(opts)
      vim.cmd.colorscheme("aki")
    end,
  },
  {
    "thesimonho/kanagawa-paper.nvim",
    lazy = true,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("kanagawa-paper-ink")
    end,
  },
}
