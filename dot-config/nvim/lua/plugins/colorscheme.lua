-- .config/nvim/lua/plugins/colorscheme.lua

return {
  {
    "AlexvZyl/nordic.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local nordic = require("nordic")
      nordic.setup({
        bold_keywords = true,
        italic_comments = true,
        reduced_blue = true,
        swap_backgrounds = true,
        on_highlight = function(highlights, palette)
          -- Distinguish cursorline from Visual
          highlights.Visual = {
            bg = palette.gray1,
          }
        end,
      })
      vim.cmd.colorscheme("nordic")
    end,
  },

  {
    "webhooked/kanso.nvim",
    enabled = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("kanso-zen")
    end,
  },
}
