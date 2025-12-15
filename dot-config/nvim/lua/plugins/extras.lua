-- .config/nvim/lua/plugins/extras.lua
-- Nice-to-have/aesthetic plugins

return {
  {
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
      disabled_filetypes = {
        ["dropbar_menu"] = true,
        ["dropbar_menu_fzf"] = true,
        ["dropbar_preview"] = true,
      },

      hints = {
        ["ggVG:"] = {
          message = function() return "Use :% instead of ggVG: to operate on the entire document" end,
          length = 5,
        },
        ["[dcyvV][ia][%(%)]"] = {
          message = function(keys) return "Use " .. keys:sub(1, 2) .. "b instead of " .. keys end,
          length = 3,
        },
        ["[dcyvV][ia][%{%}]"] = {
          message = function(keys) return "Use " .. keys:sub(1, 2) .. "B instead of " .. keys end,
          length = 3,
        },
      },
    },
  },
}
