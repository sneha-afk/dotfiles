-- ~/.config/nvim/lua/plugins/telescope.lua

return {
  {
    "nvim-telescope/telescope.nvim",
    event = "VeryLazy",
    cmd = "Telescope",
    keys = {
      { "<leader>fb", "<cmd>Telescope buffers<cr>",     desc = "[F]ind [B]uffers" },
      { "<leader>fc", "<cmd>Telescope commands<cr>",    desc = "[F]ind [C]ommands" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "[F]ile [D]iagnostics" },
      { "<leader>ff", "<cmd>Telescope find_files<cr>",  desc = "[F]ind [F]iles" },
      {
        "<leader>fe",
        "<cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>", -- From current buffer
        desc = "[F]ile [E]xplorer"
      },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>",            desc = "[F]ind [H]elp Tags" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>",             desc = "[F]ind [R]ecent files" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "[F]ile/Document [S]ymbols" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",            desc = "[F]ind by [G]rep" },
      { "<leader>gs", "<cmd>Telescope git_status<cr>",           desc = "[G]it [S]tatus" },
      { "<leader>gc", "<cmd>Telescope git_commits<cr>",          desc = "[G]it [C]ommits" },
      { "<leader>gb", "<cmd>Telescope git_branches<cr>",         desc = "[G]it [B]ranches" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-ui-select.nvim", -- Set vim.ui.select to telescope
      "nvim-telescope/telescope-file-browser.nvim",
    },
    opts = function()
      local actions = require("telescope.actions")

      -- From LazyVim
      local function find_command()
        if 1 == vim.fn.executable("rg") then
          return { "rg", "--files", "--color", "never", "-g", "!.git" }
        elseif 1 == vim.fn.executable("fd") then
          return { "fd", "--type", "f", "--color", "never", "-E", ".git" }
        elseif 1 == vim.fn.executable("fdfind") then
          return { "fdfind", "--type", "f", "--color", "never", "-E", ".git" }
        elseif 1 == vim.fn.executable("find") and vim.fn.has("win32") == 0 then
          return { "find", ".", "-type", "f" }
        elseif 1 == vim.fn.executable("where") then
          return { "where", "/r", ".", "*" }
        end
      end

      return {
        defaults = {
          mappings = {
            i = {
              ["<ESC>"] = actions.close,
              ["<C-u>"] = false, -- Clear the prompt
            },
          },
          file_ignore_patterns = { "node_modules", ".git", ".cache", "%.o", "%.out", },
          layout_strategy = "flex",
          layout_config = {
            horizontal = {
              preview_width = 0.55,
              height = 0.9,
              width = 0.95,
            },
            vertical = { width = 0.8 },
          },
        },
        pickers = {
          find_files = {
            find_command = find_command,
            hidden = true,
          },
          buffers = {
            sort_lastused = true,
          },
        },
        extensions = {
          file_browser = {
            dir_icon = "🗀",
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
