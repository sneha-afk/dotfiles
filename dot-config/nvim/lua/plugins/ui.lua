-- .config/nvim/lua/plugins/ui.lua

return {
  -- Display diff signs in gutter
  {
    "echasnovski/mini.diff",
    version = false,
    event = "UIEnter",
    keys = {
      {
        "<leader>gd",
        function() require("mini.diff").toggle_overlay(0) end,
        desc = "[G]it: toggle [D]iff Overlay",
      },
    },
    opts = {
      view = {
        style = "sign",
        signs = { add = "┃", change = "┇", delete = "━" },
      },
    },
    config = function(_, opts)
      require("mini.diff").setup(opts)

      vim.api.nvim_set_hl(0, "MiniDiffSignAdd",        { link = "DiffAdd" })
      vim.api.nvim_set_hl(0, "MiniDiffSignChange",     { link = "DiffChange" })
      vim.api.nvim_set_hl(0, "MiniDiffSignDelete",     { link = "DiffDelete" })

      vim.api.nvim_set_hl(0, "MiniDiffOverAdd",        { link = "DiffAdd" })
      vim.api.nvim_set_hl(0, "MiniDiffOverChange",     { link = "DiffChange" })
      vim.api.nvim_set_hl(0, "MiniDiffOverChangeBuf",  { link = "Comment" })
      vim.api.nvim_set_hl(0, "MiniDiffOverContext",    { link = "Comment" })
      vim.api.nvim_set_hl(0, "MiniDiffOverContextBuf", { link = "Comment" })
      vim.api.nvim_set_hl(0, "MiniDiffOverDelete",     { link = "DiffDelete" })
    end,
  },

  -- Rainbow brackets/delimiters for clarity
  {
    "HiPhish/rainbow-delimiters.nvim",
    lazy = false,
    ---@module "rainbow-delimiters"
    ---@type rainbow_delimiters.config
    opts = {
      query = {
        [""] = "rainbow-delimiters",
        lua = "rainbow-blocks",
        latex = "rainbow-blocks",
      },
      -- Defines list of highlights to cycle through
      highlight = {
        "Character",
        "PreProc",
        "Boolean",
        "Special",
        "Statement",
        "Type",
      },
    },
    config = function(_, opts)
      require("rainbow-delimiters.setup").setup(opts)
    end,
  },
}
