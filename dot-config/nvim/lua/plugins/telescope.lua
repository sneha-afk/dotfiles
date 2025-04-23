-- ~/.config/nvim/lua/plugins/telescope.lua

return {
  {
    "nvim-telescope/telescope.nvim",
    event = "VeryLazy",
    cmd = "Telescope",
    keys = {
      { "<leader>fb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "[F]ind within [B]uffer" },
      { "<leader>fB", "<cmd>Telescope buffers<cr>",                   desc = "[F]ind open [B]uffers" },
      { "<leader>fc", "<cmd>Telescope commands<cr>",                  desc = "[F]ind [C]ommands" },
      { "<leader>fC", "<cmd>Telescope command_history<cr>",           desc = "[F]ind [C]ommand History" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>",               desc = "[F]ile [D]iagnostics" },
      {
        "<leader>fe",
        "<cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>", -- From current buffer
        desc = "[F]ile [E]xplorer"
      },
      { "<leader>ff", "<cmd>Telescope find_files<cr>",           desc = "[F]ind [F]iles" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",            desc = "[F]ind by [G]rep" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>",            desc = "[F]ind [H]elp Tags" },
      { "<leader>fm", "<cmd>Telescope marks<cr>",                desc = "[F]ind [M]arks" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>",             desc = "[F]ind [R]ecent files" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "[F]ile/Document [S]ymbols" },
      { "<leader>gb", "<cmd>Telescope git_branches<cr>",         desc = "[G]it [B]ranches" },
      { "<leader>gc", "<cmd>Telescope git_commits<cr>",          desc = "[G]it [C]ommits" },
      { "<leader>gs", "<cmd>Telescope git_status<cr>",           desc = "[G]it [S]tatus" },
      { "<leader>gS", "<cmd>Telescope git_stash<cr>",            desc = "[G]it [S]tash" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-ui-select.nvim", -- Set vim.ui.select to telescope
      "nvim-telescope/telescope-file-browser.nvim",
    },
    opts = function()
      local actions = require("telescope.actions")
      local utils = require("telescope.utils")

      -- https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#find-files-from-project-git-root-with-fallback
      local function is_git_repo()
        vim.fn.system("git rev-parse --is-inside-work-tree")
        return vim.v.shell_error == 0
      end
      local function get_git_root()
        local dot_git_path = vim.fn.finddir(".git", ".;")
        return vim.fn.fnamemodify(dot_git_path, ":h")
      end

      ---@return string Root to start searching from
      local function start_search_path()
        if is_git_repo then
          return get_git_root()
        else
          return utils.buffer_dir()
        end
      end

      return {
        defaults = {
          -- Mappings within a Telescope prompt
          mappings = {
            i = {
              ["<ESC>"] = actions.close,
              ["<C-h>"] = "which_key",
            },
          },
          file_ignore_patterns = { "node_modules", ".git", ".cache", "%.o", "%.out", },
          layout_strategy = "flex",
          layout_config = {
            horizontal = {
              preview_width = 0.6,
              height = 0.9,
              width = 0.95,
            },
            vertical = { width = 0.8 },
          },
          preview = {
            filesize_limit = 0.25, -- MB
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            cwd = start_search_path(),
          },
          live_grep = {
            cwd = start_search_path(),
          },
          buffers = {
            sort_lastused = true,
          },
        },
        extensions = {
          file_browser = {
            dir_icon = "🖿",
            hijack_netrw = true,
            hidden = true,
            grouped = true,
            respect_gitignore = true,
          },
        },
      }
    end,
    config = function(_, opts)
      require("telescope").setup(opts)

      -- Load extensions
      pcall(require("telescope").load_extension, "fzf")
      pcall(require("telescope").load_extension, "ui-select")
      pcall(require("telescope").load_extension, "file_browser")
    end,
  },
}
