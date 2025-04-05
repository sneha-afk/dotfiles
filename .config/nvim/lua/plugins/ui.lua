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
  {
    "nvim-lualine/lualine.nvim",
    event = "UIEnter",
    opts = {
      options = {
        theme = "auto",
        icons_enabled = false,
        disabled_filetypes = { "starter", "ministarter" },
        always_show_tabline = false,
      },
      extensions = { "oil", },
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
              spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
              done = "✓",
              separator = " ",
            },
            ignore_lsp = {},
          },
          "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      -- Inactive windows default: only show filename and location
      tabline = {
        lualine_a = { "buffers" },
        lualine_z = { "tabs" }
      },
    },
  },
  -- Display diff signs in gutter
  {
    "echasnovski/mini.diff",
    version = false,
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      view = {
        style = "sign",
        signs = { add = "+", change = "~", delete = "-" }
      },
    },
  },
  -- Snacks!
  {
    "folke/snacks.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "echasnovski/mini.diff", },
    opts = {
      indent = {
        enabled = true,
        animate = { enabled = false },
      },
      statuscolumn = {
        enabled = true,
        fold = { open = true },
      },
    },
  },
}
