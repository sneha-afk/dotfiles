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

    delete_to_trash = not vim.g.is_ssh,
    view_options = {
      show_hidden = false,
      is_always_hidden = require("utils.globs").ignore,
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
    keymaps_help = {
      border = "rounded",
    },
  },
  config = function(_, opts)
    require("oil").setup(opts)

    -- https://github.com/folke/snacks.nvim/blob/main/docs/rename.md#oilnvim
    vim.api.nvim_create_autocmd("User", {
      pattern = "OilActionsPost",
      callback = function(event)
        if event.data.actions[1].type == "move" then
          Snacks.rename.on_rename_file(event.data.actions[1].src_url, event.data.actions[1].dest_url)
        end
      end,
    })
  end,
}
