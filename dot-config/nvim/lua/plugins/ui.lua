-- .config/nvim/lua/plugins/ui.lua

return {
  {
    "nvim-mini/mini.icons",
    lazy = true,
    version = false,
    opts = {
      style = vim.g.use_icons and "glyph" or "ascii",
    },
    config = function(_, opts)
      local icons = require("mini.icons")
      icons.setup(opts)
      icons.mock_nvim_web_devicons()
    end,
  },
  -- Rainbow brackets/delimiters for clarity
  {
    "HiPhish/rainbow-delimiters.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = { "BufReadPost", "BufNewFile" },
    ---@module "rainbow-delimiters"
    ---@type rainbow_delimiters.config
    opts = {
      query = {
        [""] = "rainbow-delimiters",
        lua = "rainbow-blocks",
        latex = "rainbow-blocks",
        javascript = "rainbow-delimiters-react",
        typescript = "rainbow-parens",
        tsx = "rainbow-tags-react",
        typescriptreact = "rainbow-tags-react",
      },
      priority = {
        [""] = 145,
        latex = 210,
        lua = 210,
      },
      highlight = require("utils.ui").color_cycle,
    },
    main = "rainbow-delimiters.setup",
  },
  {
    "akinsho/bufferline.nvim",
    version = "*",
    lazy = false,
    dependencies = {
      "lewis6991/gitsigns.nvim",
      "nvim-mini/mini.icons",
    },
    keys = {
      { "<Tab>",      "<CMD>BufferLineCycleNext<CR>", desc = "Next buffer" },
      { "<S-Tab>",    "<CMD>BufferLineCyclePrev<CR>", desc = "Prev buffer" },
      { "<leader>bp", "<CMD>BufferLinePick<CR>",      desc = "[B]uffers: [P]ick" },
      { "<leader>tp", "<CMD>BufferLineTogglePin<CR>", desc = "[T]abs: toggle [P]in" },
      {
        "<leader>tr",
        function()
          vim.ui.input({ prompt = "Rename tabpage: " }, function(input)
            if input and input ~= "" then vim.cmd("BufferLineTabRename " .. input) end
          end)
        end,
        desc = "[T]abs: [R]ename",
      },
    },
    opts = function()
      local bufferline = require("bufferline")
      local groups = require("bufferline.groups")

      return {
        options = {
          mode = "buffers",
          style_preset = bufferline.style_preset.no_italic,
          separator_style = "slant",

          modified_icon = "●",
          close_icon = "🞬",
          buffer_close_icon = "🞬",
          left_trunc_marker = "🡨 ",
          right_trunc_marker = "🡪 ",

          groups = {
            items = {
              groups.builtin.pinned:with({
                icon = vim.g.use_icons and "󰐃" or "🟊",
              }),
              {
                name = "tests",
                priority = 2,
                matcher = function(buf)
                  return buf.path:match("_test") or buf.path:match("_spec")
                end,
              },
              {
                name = "docs",
                auto_close = false,
                matcher = function(buf)
                  return buf.path:match("%.md$") or buf.path:match("%.txt$")
                end,
              },
              groups.builtin.ungrouped,
            },
          },
        },
      }
    end,
  },
}
