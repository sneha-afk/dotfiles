-- .config/nvim/lua/plugins/colorscheme.lua

return {
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
    end
  },
  {
    "thesimonho/kanagawa-paper.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("kanagawa-paper-ink")
    end,
  },
  {
    "vague2k/vague.nvim",
    lazy = true,
    priority = 1000,
    opts = {
    },
    config = function(_, opts)
      require("vague").setup(opts)
      vim.cmd.colorscheme("vague")
    end
  },
}
