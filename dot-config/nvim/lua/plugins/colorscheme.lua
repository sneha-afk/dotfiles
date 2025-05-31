-- .config/nvim/lua/plugins/colorscheme.lua

return {
  {
    "webhooked/kanso.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("kanso-ink")
    end,
  },
  {
    "thesimonho/kanagawa-paper.nvim",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("kanagawa-paper-ink")
    end,
  },
}
