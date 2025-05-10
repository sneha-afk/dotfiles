-- .config/nvim/lua/plugins/ui.lua

return {
  -- Display diff signs in gutter
  {
    "echasnovski/mini.diff",
    version = false,
    event = "UIEnter",
    keys = {
      { "<leader>gd", function() require("mini.diff").toggle_overlay() end, desc = "[G]it: toggle [D]iff Overlay" },
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
    lazy = false,
    priority = 1000,
    dependencies = { "echasnovski/mini.diff", },
    opts = {
      indent = {
        enabled = true,
        animate = { enabled = false },
      },
      input = {
        enabled = true,
        icon = "> ",
      },
      statuscolumn = {
        enabled = true,
        fold = { open = true },
      },
      toggle = {
        enabled = true,
        icon = {
          enabled = "●",
          disabled = "○",
        },
      },
      zen = {
        enabled = true,
        on_open = function(win)
          vim.cmd("set nu!")
        end,
      },
      styles = {
        input = {
          relative = "cursor",
          position = "float",
        },
        zen = {
          relative = "editor",
          width = 0.6,
          backdrop = { transparent = true, blend = 20 },
        },
      },
      notifier = {
        timeout = 3000,   -- in ms
        top_down = false, -- false for bottom up
        icons = {
          error = "[E] ",
          warn  = "[W] ",
          info  = "[I] ",
          debug = "[D] ",
          trace = "[T] ",
        },
      },
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          Snacks.toggle.indent():map("<leader>ui")
          Snacks.toggle.zen():map("<leader>z")
        end,
      })
    end,
  },
}
