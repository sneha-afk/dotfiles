-- .config/nvim/lua/plugins/hardtime.lua

return {
  "m4xshen/hardtime.nvim",
  event = "VeryLazy",
  keys = {
    {
      "<leader>hd",
      function()
        vim.cmd("Hardtime disable")
        vim.notify("Hardtime disabled", vim.log.levels.INFO)
      end,
      desc = "[H]ardtime: [d]isable",
    },
    { "<leader>hT", "<cmd>Hardtime toggle<cr>", desc = "[H]ardtime: [T]oggle" },
  },
  opts = {
    disable_mouse = false,
    restricted_keys = {
      -- ["h"] = false,
      ["j"] = false,
      ["k"] = false,
      -- ["l"] = false,
    },
    -- let me live pls
    disabled_keys = {
      ["<Up>"] = false,
      ["<Down>"] = false,
      ["<Left>"] = false,
      ["<Right>"] = false,
    },
  },
}
