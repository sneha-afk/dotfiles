-- .config/nvim/lua/plugins/colorscheme.lua

return {
  {
    "comfysage/aki",
    lazy = false,
    priority = 1000,
    opts = {
      contrast_dark = true,
      override_terminal = true,
    },
    config = function(_, opts)
      require("aki").setup(opts)
      vim.cmd.colorscheme("aki")
    end
  },
  {
    "thesimonho/kanagawa-paper.nvim",
    lazy = true,
    config = function()
      vim.cmd.colorscheme("kanagawa-paper-ink")
    end,
  },
  {
    "AlexvZyl/nordic.nvim",
    lazy = true,
    opts = {
      swap_backgrounds = true,
    },
    config = function(_, opts)
      require("nordic").setup(opts)
      vim.cmd.colorscheme("nordic")
    end
  },
}
