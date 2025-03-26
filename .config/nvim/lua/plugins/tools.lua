return {
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    config = function()
      require("nvim-tree").setup({
        -- ======================
        -- Window Layout & Appearance
        -- ======================
        view = {
          width = 30,
          side = "left",
          number = false,
          signcolumn = "no",
          relativenumber = false,
        },

        -- ======================
        -- File Display & Icons
        -- ======================
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
          },

          highlight_git = true,   -- Color files based on git status
          add_trailing = false,   -- Remove trailing slashes on folders
        },

        -- ======================
        -- File Filtering
        -- ======================
        filters = {
          dotfiles = false,       -- Show hidden files
          custom = { "^.git$" },  -- Except .git directory
        },

        -- ======================
        -- Behavior & Functionality
        -- ======================
        actions = {
          -- Upon opening a file
          open_file = {
            quit_on_open = false,
          },
          -- Upon changing directory
          change_dir = {
            enable = true,        -- Change Vim's CWD when changing tree root
            global = true,        -- Change CWD globally (all windows)
          }
        },

        update_focused_file = {
          enable = true,          -- Auto-refresh tree when focusing files
          update_root = true,     -- Update root when focusing files
          update_cwd = true,      -- Update CWD when focusing files
        },

        hijack_cursor = true,     -- Move cursor to tree when opening

        -- ======================
        -- Integrations
        -- ======================
        git = {
          enable = false,         -- Disable git integration
          ignore = true,          -- Show gitignored files
          timeout = 500,          -- Git operation timeout (ms)
        },

        diagnostics = {
          enable = false,         -- Disable LSP diagnostics
          show_on_dirs = false,   -- Don't show diagnostics on directories
        }
      })
    end
  }
}