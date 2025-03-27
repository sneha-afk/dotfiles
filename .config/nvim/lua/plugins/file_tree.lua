-- .config/nvim/lua/plugins/file_tree.lua

local function ignore_files(name)
  return name == ".git"
    or name == "node_modules"
    or name:match("%.lock$")
    or name:match("^%..*%.swp$")
    or name == ".DS_Store"
    or name:match("^__pycache__$")
    or name:match("%.py[co]$")
end

return {
  {
    "stevearc/oil.nvim",
    keys = {
      { "<leader>n", "<cmd>Oil --float<cr>", desc = "File browser" },
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
    },
    cmd = { "Oil", "Oil --float" },
    opts = {
      constrain_cursor = "name",
      delete_to_trash = true, -- Go to system trash instead of permanently deleting

      -- Unified filtering across all features
      view_options = {
        show_hidden = true,
        is_always_hidden = ignore_files,
      },

      -- File operations filtering
      skip_confirm_for_simple_edits = true,
      prompt_save_on_select_new_entry = false,
      cleanup_delay_ms = 2000,

      -- Column display
      columns = {
        {
          "size",
          highlight = "Number",
        },
        "icon",
      },

      -- Window styling (applies filter to all views)
      win_options = {
        cursorline = true,
        winblend = 5,
        list = false,
      },

      -- Float window
      float = {
        padding = 2,
        max_width = 0.95,
        max_height = 0.75,
      },
    },
  },
}
