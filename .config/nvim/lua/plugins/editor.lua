-- .config/nvim/lua/plugins/editor.lua
-- Plugins for enhancing the direct editing experience: auto-pairing, comments

return {
  -- Auto-pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      enable_check_bracket_line = false,
      ignored_next_char = "[%w%.]", -- Don't pair after letters/numbers
    },
  },

  -- Remove whitespace and blank lines at EOF on save
  {
    "mcauley-penney/tidy.nvim",
    event = "BufWritePre",
    opts = {
      filetype_exclude = { "markdown", "diff", "gitcommit", },
      buftype_exclude = { "nofile", "terminal", "prompt", },
    },
  },


  -- Commenting
  {
    "numToStr/Comment.nvim",
    keys = {
      { "<leader>cc", desc = "Toggle line comment" },
      { "<leader>bc", desc = "Toggle block comment" },
      { "<leader>c",  desc = "Comment selection (linewise)",  mode = "v", },
      { "<leader>b",  desc = "Comment selection (blockwise)", mode = "v", },
    },
    opts = {
      padding = true, -- Adds space after comment symbol
      sticky = true,  -- Cursor stays in place
      toggler = {
        line = "<leader>cc",
        block = "<leader>bc",
      },
      opleader = {
        line = "<leader>c",
        block = "<leader>b",
      },
    },
  },

  -- Git integration with vim-fugitive
  {
    "tpope/vim-fugitive",
    cmd = { "Git" },
    keys = {
      { "<leader>gs", "<cmd>Git<CR>",        desc = "Git status" },
      { "<leader>gc", "<cmd>Git commit<CR>", desc = "Git commit" },
      { "<leader>gl", "<cmd>Git log<CR>",    desc = "Git log" },
      { "<leader>gd", "<cmd>Git diff<CR>",   desc = "Git diff" },
      { "<leader>gb", "<cmd>Git blame<CR>",  desc = "Git blame" },
    },
  },

  -- whichkey: yes pls
  {
    "folke/which-key.nvim",
    event = { "VimEnter" },
    opts = {
      preset = "modern",
      win = {
        border = "rounded",
        title = " Keybindings ",
      },
      icons = {
        mappings = false,
        rules = false,
        keys = {
          Up = "^ ",
          Down = "v ",
          Left = "< ",
          Right = "> ",
          C = "^-",
          M = "m-",
          D = "dd",
          S = "s-",
          CR = "cr",
          Esc = "esc ",
          ScrollWheelDown = "v",
          ScrollWheelUp = "^ ",
          NL = "nl",
          BS = "bs",
          Space = "_",
          Tab = ">>",
          F1 = "f1",
          F2 = "f2",
          F3 = "f3",
          F4 = "f4",
          F5 = "f5",
          F6 = "f6",
          F7 = "f7",
          F8 = "f8",
          F9 = "f9",
          F10 = "f10",
          F11 = "f11",
          F12 = "f12",
        },
      },
    },
  },
}
