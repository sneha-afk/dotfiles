-- .config/nvim/lua/plugins/oil.lua

local function ignore_files(name)
  -- Hash table to quickly return true
  local static_ignores = {
    [".git"] = true,
    ["node_modules"] = true,
    ["__pycache__"] = true,
    [".DS_Store"] = true,
    ["package-lock.json"] = true,
    ["yarn.lock"] = true,
    ["Cargo.lock"] = true,
  }

  -- Dynamic patterns (compiled once)
  local pattern_ignores = {
    "%.lock$",
    "^%..*%.swp$",
    "%.py[co]$",
    "^[dD]ebug$",
    "^[rR]elease$",
    "^target$",
    "^dist$",
    "^build$",
    "^venv$",
    "^%.venv$",
    "^%.cache$",
  }

  -- O(1) lookup -> fast path
  if static_ignores[name] then
    return true
  end

  for _, pattern in ipairs(pattern_ignores) do
    if name:match(pattern) then
      return true
    end
  end

  return false
end

return {
  {
    "stevearc/oil.nvim",
    keys = {
      { "<leader>n", "<cmd>Oil --float<cr>", desc = "File browser (float)" },
      { "-",         "<cmd>Oil<cr>",         desc = "File browser" },
    },
    cmd = { "Oil", "Oil --float" },
    opts = {
      constrain_cursor = "name",

      -- System trash instead of permanently deleting
      delete_to_trash = true,

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
        {
          "mtime",
          format = "%Y-%m-%d %H:%M",
          highlight = "Define",
        },
      },

      -- Window styling (applies filter to all views)
      win_options = {
        cursorline = true,
        winblend = 5,
      },

      -- Float window
      float = {
        padding = 2,
        max_width = 0.95,
        max_height = 0.70,
      },
    },
  },
}
