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

  -- Commenting
  {
    "numToStr/Comment.nvim",
    keys = {
      { "<leader>cc", desc = "Toggle line comment" },
      { "<leader>bc", desc = "Toggle block comment" },
      { "<leader>c", mode = "v", desc = "Comment selection (linewise)" },
      { "<leader>b", mode = "v", desc = "Comment selection (blockwise)" },
    },
    opts = {
      padding = true, -- Adds space after comment symbol
      sticky = true, -- Cursor stays in place
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
    init = function()
      -- Set keymaps in init (will work whenever plugin loads)
      vim.keymap.set("n", "<leader>gs", "<cmd>Git<CR>", { desc = "Git status" })
      vim.keymap.set("n", "<leader>gc", "<cmd>Git commit<CR>", { desc = "Git commit" })
      vim.keymap.set("n", "<leader>gl", "<cmd>Git log<CR>", { desc = "Git log" })
      vim.keymap.set("n", "<leader>gd", "<cmd>Git diff<CR>", { desc = "Git diff" })
      vim.keymap.set("n", "<leader>gb", "<cmd>Git blame<CR>", { desc = "Git blame" })
    end,
  },

  -- whichkey: yes pls
  {
    "folke/which-key.nvim",
    event = { "VimEnter" },
    opts = {
      preset = "modern",
      icons = {
        mappings = false,
        rules = false,
        breadcrumb = ">",
        separator = ">",
        ellipsis = ".",
        -- stylua: ignore start
        keys = {
          Up = "^ ", Down = "v ", Left = "< ", Right = "> ",
          C = "^-", M = "m-", D = "dd", S = "s-",
          CR = "cr", Esc = "esc ",
          ScrollWheelDown = "v", ScrollWheelUp = "^ ",
          NL = "nl", BS = "bs", Space = "_", Tab = ">>",
          F1 = "f1", F2 = "f2", F3 = "f3", F4 = "f4",
          F5 = "f5", F6 = "f6", F7 = "f7", F8 = "f8",
          F9 = "f9", F10 = "f10", F11 = "f11", F12 = "f12",
        },
        -- stylua: ignore end
      },
      win = {
        border = "rounded",
        title = " Keybindings ",
      },
    },
  },
}
