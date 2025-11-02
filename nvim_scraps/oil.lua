-- .config/nvim/lua/plugins/oil.lua

local fileopts = require("core.utils.fileops")

return {
  "stevearc/oil.nvim",
  cmd = "Oil",
  keys = {
    { "<leader>e", "<cmd>Oil --float<cr>", desc = "Open files" },
    { "-",         "<cmd>Oil<cr>",         desc = "Open file tree" },
  },
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    -- Oil will take over directory buffers (e.g. `vim .` or `:e src/`)
    default_file_explorer = true,

    -- System trash instead of permanently deleting
    delete_to_trash = true,

    -- File operations filtering
    skip_confirm_for_simple_edits = true,
    prompt_save_on_select_new_entry = false,
    cleanup_delay_ms = 2000,
    constrain_cursor = "name",

    view_options = { -- Unified filtering across all features
      show_hidden = true,
      is_always_hidden = fileopts.ignore,
    },
    columns = {
      -- "icon",
      -- "permissions",
      {
        "size",
        highlight = "Number",
        format = function(size)
          if size < 1024 then
            return tostring(size) .. "B"
          elseif size < 1024 * 1024 then
            return string.format("%.1fK", size / 1024)
          else
            return string.format("%.1fM", size / (1024 * 1024))
          end
        end,
      },
      {
        "mtime",
        format = "%Y-%m-%d %H:%M",
        highlight = "Define",
      },
    },

    buf_options = {
      buflisted = false,
      bufhidden = "hide",
    },
    win_options = {
      cursorline = true,
      winblend = 5,
    },
    float = {
      max_width = 0.95,
      max_height = 0.70,
      border = "rounded",
    },

    keymaps = {
      ["<localleader>p"] = "actions.preview",
      ["q"] = { "actions.close", mode = "n" }, -- C-c or q to close
    },
  },
}
