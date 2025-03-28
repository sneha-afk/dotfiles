-- .config/nvim/lua/plugins/ui.lua
-- UI configurations: plugin-managed colorschemes and status line

return {
  -- Colorscheme
  {
    "vague2k/vague.nvim",
    lazy = false,
    config = function()
      local status, _ = pcall(vim.cmd.colorscheme, "vague")
      if not status then
        vim.notify("Colorscheme not found! Falling back to default", vim.log.levels.ERROR)
        vim.cmd.colorscheme("habamax")
      end
    end,
  },

  -- Git markers in the status column
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },

  -- Status Line
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "auto",
        icons_enabled = false,
        disabled_filetypes = { "starter", "ministarter" },
        always_show_tabline = false,
      },
      extensions = { "oil", "fugitive", },
      -- A, B, C are left; X, Y, Z are right
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "filename", },
        lualine_c = { "branch", "diff", "diagnostics", },
        lualine_x = {
          {
            "lsp_status",
            icon = "",
            symbols = {
              -- Standard unicode symbols to cycle through for LSP progress:
              spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
              done = '✓',
              separator = ' ',
            },
            -- List of LSP names to ignore (e.g., `null-ls`):
            ignore_lsp = {},
          },
          "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      -- Inactive windows default: only show filename and location
      tabline = {
        lualine_a = { 'buffers' },
        lualine_z = { 'tabs' }
      },

    },
  },

  -- Snacks!
  {
    "folke/snacks.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      indent = {
        enabled = true,
        animate = { enabled = false },
      },
      statuscolumn = { enabled = true },
    },
  },
}
