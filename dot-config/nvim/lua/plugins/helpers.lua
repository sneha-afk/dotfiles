-- ./config/nvim/lua/plugins/helpers.lua
-- Helpful utilities

local colorizer_fts = { "css", "scss", "sass", "less", "html" }

return {
  {
    "nvim-mini/mini.pairs",
    event = "InsertEnter",
    version = false,
    config = true,
  },
  {
    "nvim-mini/mini.surround",
    event = "ModeChanged *:[vV\x16]*", -- Load on Visual
    version = false,
    config = true,
  },
  {
    "norcalli/nvim-colorizer.lua",
    ft = colorizer_fts,
    opts = {
      "*", -- Highlight all filetypes with default opts
      css = { rgb_fn = true },
      scss = { rgb_fn = true },
      sass = { rgb_fn = true },
    },
    config = function(_, opts)
      local colorizer = require("colorizer")
      colorizer.setup(opts)

      vim.api.nvim_create_autocmd("FileType", {
        pattern = colorizer_fts,
        callback = function(args)
          colorizer.attach_to_buffer(args.buf)
        end,
      })
    end,
  },
}
