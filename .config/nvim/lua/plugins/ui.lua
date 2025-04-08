-- .config/nvim/lua/plugins/ui.lua
-- UI configurations: plugin-managed colorschemes and status line

return {
  -- Colorscheme
  {
    "vague2k/vague.nvim",
    lazy = false,
    config = function()
      vim.cmd.colorscheme("vague")
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "auto",
        icons_enabled = false,
        disabled_filetypes = { "starter", "ministarter" },
        always_show_tabline = false,
      },
      -- A, B, C are left; X, Y, Z are right
      sections = {
        lualine_b = { "filename", },
        lualine_c = { "branch", "diff", "diagnostics", },
        lualine_x = {
          {
            "lsp_status",
            icon = "",
            ignore_lsp = {},
          },
          "filetype"
        },
      },
      -- Inactive windows default: only show filename and location
      tabline = {
        lualine_a = { "buffers" },
        lualine_z = { "tabs" }
      },
    },
  },
  -- Display diff signs in gutter
  {
    "echasnovski/mini.diff",
    version = false,
    event = "UIEnter",
    keys = {
      { "<leader>gd", function() require("mini.diff").toggle_overlay() end, desc = "[G]it [D]iff Overlay" },
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
