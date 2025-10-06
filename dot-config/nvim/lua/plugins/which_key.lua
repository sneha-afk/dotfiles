-- .config/nvim/lua/plugins/which_key.lua

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  keys = {
    {
      "<leader>?",
      function() require("which-key").show({ global = false }) end,
      desc = "View local buffer keymaps",
    },
  },
  ---@module "which-key"
  ---@type wk.Opts
  opts = {
    preset = "helix",
    ---@type wk.Win.opts
    win = {
      border = "rounded",
      width = { min = vim.o.columns / 5, max = vim.o.columns / 2 },
      height = { min = 4, max = vim.o.lines / 2 },
      title = " Keybindings ",
    },
    keys = {
      scroll_down = "<C-j>",
      scroll_up = "<C-k>",
    },
    icons = {
      mappings = false,
      rules = false,
      keys = {
        Up = "↑ ",
        Down = "↓ ",
        Left = "← ",
        Right = "→ ",
        C = "c-",
        M = "m-",
        D = "dd",
        S = "s-",
        CR = "cr",
        Esc = "esc ",
        ScrollWheelDown = "↓",
        ScrollWheelUp = "↑ ",
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
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    wk.add({
      { "<leader>b", group = "Buffer" },
      { "<leader>c", group = "Code actions" },
      { "<leader>d", group = "Diagnostics" },
      { "<leader>h", group = "Horizontal" },
      { "<leader>v", group = "Vertical" },
      { "<leader>f", group = "File/Find" },
      { "<leader>g", group = "Git" },
      { "<leader>s", group = "Search" },
      { "<leader>t", group = "Tabs" },
      { "<leader>u", group = "UI" },
      { "<leader>W", group = "Workspace" },
      { "<leader>l", group = "LSP" },
      { "<leader>L", group = "LaTeX" },
      { "<leader>[", group = "Previous" },
      { "<leader>]", group = "Next" },
    })
  end,
}
