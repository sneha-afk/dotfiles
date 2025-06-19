-- ./config/nvim/lua/plugins/helpers.lua
-- Helpful utilities

return {
  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    version = false,
    config = true,
  },
  {
    "echasnovski/mini.surround",
    event = "ModeChanged *:[vV\x16]*", -- Load on Visual
    version = false,
    config = true,
  },
  {
    "norcalli/nvim-colorizer.lua",
    event = "VeryLazy",
    opts = {
      "*", -- Highlight all filetypes with default opts
      css = { rgb_fn = true },
      scss = { rgb_fn = true },
      sass = { rgb_fn = true },
      html = { mode = "foreground" },
      vue = { mode = "foreground" },
      svelte = { mode = "foreground" },
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          vim.cmd("ColorizerAttachToBuffer")
        end,
      })
    end,
  },
}
