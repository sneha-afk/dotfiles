-- .config/nvim/lua/plugins/ui.lua

return {
  -- Display diff signs in gutter
  {
    "echasnovski/mini.diff",
    version = false,
    event = "UIEnter",
    keys = {
      { "<leader>gd", function() require("mini.diff").toggle_overlay() end,  desc = "Toggle [G]it [D]iff Overlay" },
      { "<leader>gD", function() require("mini.diff").toggle_overlay(1) end, desc = "Toggle [G]it [D]iff all buffers" },
    },
    opts = {
      view = {
        style = "sign",
        signs = { add = "┃", change = "┇", delete = "━" },
      },
    },
    config = function(_, opts)
      require("mini.diff").setup(opts)

      vim.api.nvim_set_hl(0, "MiniDiffSignAdd", { link = "DiffAdd" })
      vim.api.nvim_set_hl(0, "MiniDiffSignChange", { link = "DiffChange" })
      vim.api.nvim_set_hl(0, "MiniDiffSignDelete", { link = "DiffDelete" })

      vim.api.nvim_set_hl(0, "MiniDiffOverAdd", { link = "DiffAdd" })
      vim.api.nvim_set_hl(0, "MiniDiffOverChange", { link = "DiffChange" })
      vim.api.nvim_set_hl(0, "MiniDiffOverChangeBuf", { link = "Comment" })
      vim.api.nvim_set_hl(0, "MiniDiffOverContext", { link = "Comment" })
      vim.api.nvim_set_hl(0, "MiniDiffOverContextBuf", { link = "Comment" })
      vim.api.nvim_set_hl(0, "MiniDiffOverDelete", { link = "DiffDelete" })
    end
  },
  -- Snacks!
  {
    "folke/snacks.nvim",
    event = "UIEnter",
    dependencies = { "echasnovski/mini.diff", },
    opts = {
      indent = {
        enabled = true,
        animate = { enabled = false },
      },
      statuscolumn = {
        enabled = true,
        fold = { open = true },
      },
    },
  },
}
