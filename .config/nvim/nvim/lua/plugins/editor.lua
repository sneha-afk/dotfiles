return {
  -- Auto-pairs
  { 
    "windwp/nvim-autopairs", 
    event = "InsertEnter", 
    config = true  -- Use default settings
  },

  -- Commenting
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup({
        toggler = {
          line = '<leader>cc',  -- Toggle current line
          block = '<leader>bc', -- Toggle block comment
        },
        opleader = {
          line = '<leader>c',   -- Comment selection (linewise)
          block = '<leader>b',  -- Comment selection (blockwise)
        },
      })
    end,
  }
}
