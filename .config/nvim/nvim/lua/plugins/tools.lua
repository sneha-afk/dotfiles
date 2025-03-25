return {
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    config = function()
      require("nvim-tree").setup({
        view = {
          width = 30,
          side = "left",
          signcolumn = "no"
        },

        renderer = {
          indent_markers = {
            enable = true,
            icons = { corner = "└" }
          },
          icons = {
            show = {
              file = false,
              folder = false,
              folder_arrow = false,
              git = false
            }
          }
        },

        filters = {
          dotfiles = true,
          custom = { "^.git$" },
          exclude = { ".env" }
        },

        actions = {
          open_file = {
            quit_on_open = false,
            window_picker = { enable = false },
          },
          change_dir = {
            enable = true,        -- Change tree root when changing directories
            global = true,        -- Change root directory globally
          }
        },

        -- This ensures the tree updates to show current file
        update_focused_file = {
          enable = true,
          update_root = true, 
          update_cwd = true,
        },

        hijack_cursor = true,

        git = {
          enable = false,
          ignore = false,
          timeout = 500
        },
        diagnostics = {
          enable = false,
          show_on_dirs = false
        }
      })
    end
  }
}