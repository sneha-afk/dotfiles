-- ./config/nvim/lua/plugins/helpers.lua
-- Helpful utilities

return {
  -- Auto-pairs
  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    version = false,
    config = true,
  },
  -- Surrounding
  {
    "echasnovski/mini.surround",
    event = "ModeChanged *:[vV\x16]*", -- Load on Visual
    version = false,
    config = true,
  },
}
