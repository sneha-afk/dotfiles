-- .config/nvim/lua/plugins/oil.lua

return {
  "stevearc/oil.nvim",
  cmd = "Oil",
  keys = {
    { "-", "<cmd>Oil --float<cr>", desc = "Open files" },
  },
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    default_file_explorer = false,

    delete_to_trash = true,
    skip_confirm_for_simple_edits = true,
    prompt_save_on_select_new_entry = false,
    cleanup_delay_ms = 2000,
    constrain_cursor = "name",
    view_options = {
      show_hidden = false,
      is_always_hidden = require("utils.fileops").ignore,
    },
    columns = {
      -- "icon",
      -- "permissions",
      {
        "size",
        highlight = "Number",
      },
      {
        "mtime",
        format = "%Y-%m-%d %H:%M",
        highlight = "Comment",
      },
    },
    buf_options = {
      buflisted = false,
      bufhidden = "hide",
    },
    win_options = {
      cursorline = true,
      winblend = 2,
    },
    float = {
      max_width = 0.95,
      max_height = 0.85,
      border = "rounded",
    },
    keymaps = {
      ["<localleader>p"] = "actions.preview",
      ["<localleader>."] = "actions.toggle_hidden",
      ["q"] = { "actions.close", mode = "n" }, -- C-c or q to close
    },
  },
}
