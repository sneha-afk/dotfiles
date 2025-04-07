-- .config/nvim/lua/plugins/neogit.lua

return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "echasnovski/mini.pick",
      "echasnovski/mini.extra",
    },
    cmd = "Neogit",
    keys = {
      { "<leader>gn", "<cmd>Neogit<cr>",                                        desc = "[G]it: open [N]eogit" },
      { "<leader>gp", "<cmd>Neogit pull<cr>",                                   desc = "[G]it [p]ull" },
      { "<leader>gP", "<cmd>Neogit push<cr>",                                   desc = "[G]it [P]ush" },
      { "<leader>gh", function() require("mini.extra").pickers.git_hunks() end, desc = "[G]it [H]unks" },
    },
    opts = {
      kind = "tab",
      integrations = {
        mini_pick = true,
      },
      commit_editor = {
        kind = "split",
        show_staged_diff = true,
        staged_diff_split_kind = "vsplit",
        spell_check = true,
      },
    },
  }
}
