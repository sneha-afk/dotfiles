-- ~/.config/nvim/lua/plugins/telescope.lua

return {
  "nvim-telescope/telescope.nvim",
  event = "VeryLazy",
  cmd = "Telescope",
  keys = {
    { "<leader>fb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "[F]ind: within [B]uffer" },
    { "<leader>fB", "<cmd>Telescope buffers<cr>",                   desc = "[F]ind: open [B]uffers" },
    { "<leader>fc", "<cmd>Telescope commands<cr>",                  desc = "[F]ind: [C]ommands" },
    { "<leader>fC", "<cmd>Telescope command_history<cr>",           desc = "[F]ind: [C]ommand History" },
    { "<leader>fd", "<cmd>Telescope diagnostics bufnr=0<cr>",       desc = "[F]ile: [D]iagnostics" },
    {
      "<leader>fe",
      "<cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>", -- From current buffer
      desc = "[F]ile: [E]xplorer",
    },
    { "<leader>fh", "<cmd>Telescope search_history<cr>",        desc = "[F]ind: search [H]istory" },
    { "<leader>fH", "<cmd>Telescope help_tags<cr>",             desc = "[F]ind: [H]elp tags" },
    { "<leader>fm", "<cmd>Telescope marks<cr>",                 desc = "[F]ind: [M]arks" },
    { "<leader>fr", "<cmd>Telescope oldfiles<cr>",              desc = "[F]ind: [R]ecent files" },

    -- LSP operations: override system lsp.buf
    { "gd",         "<cmd>Telescope lsp_definitions<cr>",       desc = "[G]oto [d]efinition" },
    { "gi",         "<cmd>Telescope lsp_implementations<cr>",   desc = "[G]oto [i]mplementation" },
    { "gy",         "<cmd>Telescope lsp_type_definitions<cr>",  desc = "[G]oto t[y]pe definition" },
    { "gr",         "<cmd>Telescope lsp_references<cr>",        desc = "[G]oto [r]eferences" },
    { "gI",         "<cmd>Telescope lsp_incoming_calls<cr>",    desc = "[G]oto [I]ncoming calls" },
    { "gO",         "<cmd>Telescope lsp_outgoing_calls<cr>",    desc = "[G]oto [O]utgoing calls" },
    { "<leader>ls", "<cmd>Telescope lsp_document_symbols<cr>",  desc = "[L]SP: document [S]ymbols" },
    { "<leader>lS", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "[L]SP: workspace [S]ymbols" },

    -- Git operations
    { "<leader>gb", "<cmd>Telescope git_branches<cr>",          desc = "[G]it: [B]ranches" },
    { "<leader>gc", "<cmd>Telescope git_commits<cr>",           desc = "[G]it: [C]ommits" },
    { "<leader>gs", "<cmd>Telescope git_status<cr>",            desc = "[G]it: [S]tatus" },
    { "<leader>gS", "<cmd>Telescope git_stash<cr>",             desc = "[G]it: [S]tash" },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-telescope/telescope-ui-select.nvim", -- Set vim.ui.select to telescope
    "nvim-telescope/telescope-file-browser.nvim",
  },
  config = function()
    local telescope = require("telescope")

    local builtin = require("telescope.builtin")
    local actions = require("telescope.actions")
    local utils = require("telescope.utils")
    local my_utils = require("core.utils")

    -- https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#find-files-from-project-git-root-with-fallback
    ---@return string Root to start searching from
    local function start_search_path()
      if my_utils.is_git_repo() then
        return my_utils.get_git_root()
      else
        return utils.buffer_dir()
      end
    end

    telescope.setup({
      defaults = {
        mappings = {
          i = {
            ["<ESC>"] = actions.close,
            ["<C-?>"] = "which_key",
          },
        },
        file_ignore_patterns = { "node_modules", ".git", ".cache", "%.o", "%.out" },
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
    })

    -- Load extensions
    pcall(telescope.load_extension, "fzf")
    pcall(telescope.load_extension, "ui-select")
    pcall(telescope.load_extension, "file_browser")

    -- Dynamic cwd: either top of git repo, or from cwd
    vim.keymap.set("n", "<leader>ff", function()
      builtin.find_files({ cwd = start_search_path() })
    end, { desc = "[F]ind: [F]iles" })
    vim.keymap.set("n", "<leader>fg", function()
      builtin.live_grep({ cwd = start_search_path() })
    end, { desc = "[F]ind: live [G]rep" })
  end,
}
