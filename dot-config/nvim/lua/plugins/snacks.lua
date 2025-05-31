-- .config/nvim/lua/plugins/snacks.lua

return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 1000,
  dependencies = { "echasnovski/mini.diff" },
  ---@module "snacks"
  ---@type snacks.Config
  opts = {
    indent = {
      enabled = true,
      animate = { enabled = false },
      chunk = {
        enabled = true,
        char = {
          corner_top = "╭",
          corner_bottom = "╰",
          horizontal = "─",
          vertical = "│",
          arrow = "🞂",
        },
      },
    },
    input = {
      enabled = true,
      icon = "❯ ",
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
    notifier = {
      timeout = 3000,   -- in ms
      top_down = false, -- false for bottom up
      icons = {
        error = "[E] ",
        warn = "[W] ",
        info = "[I] ",
        debug = "[D] ",
        trace = "[T] ",
      },
    },
    styles = {
      input = {
        relative = "cursor",
        position = "float",
      },
      notification_history = {
        width = 0.85,
        height = 0.75,
      },
      zen = {
        relative = "editor",
        width = 0.75,
        backdrop = {
          transparent = true,
          blend = 15,
        },
      },
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        Snacks.toggle.indent():map("<leader>ui")
        Snacks.toggle.zen():map("<leader>uz")
        vim.keymap.set("n", "<leader>hn", Snacks.notifier.show_history, { desc = "[H]istory: [N]otifications" })
      end,
    })
  end,
}
