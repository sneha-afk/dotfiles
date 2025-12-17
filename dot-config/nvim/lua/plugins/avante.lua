-- .config/nvim/lua/plugins/avante.lua
-- AI completion through API keys
-- See: https://github.com/yetone/avante.nvim

-- Important: toggle used in completion setup
vim.g.enable_avante = true

return {
  "yetone/avante.nvim",
  enabled = vim.g.enable_avante,
  event = "VeryLazy",
  version = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "folke/snacks.nvim",
    "Kaiser-Yang/blink-cmp-avante",
    vim.g.use_icons and "nvim-mini/mini.icons" or "",
  },
  keys = {
    { "<leader>aa", "<cmd>AvanteAsk<cr>",            desc = "[A]I: Ask" },
    { "<leader>ac", "<cmd>AvanteChat<cr>",           desc = "[A]I: Open Chat" },
    { "<leader>an", "<cmd>AvanteChatNew<cr>",        desc = "[A]I: New Chat" },
    { "<leader>ah", "<cmd>AvanteHistory<cr>",        desc = "[A]I: Chat History" },
    { "<leader>at", "<cmd>AvanteToggle<cr>",         desc = "[A]I: Toggle Sidebar" },
    { "<leader>as", "<cmd>AvanteStop<cr>",           desc = "[A]I: Stop AI Request" },
    { "<leader>ap", "<cmd>AvanteSwitchProvider<cr>", desc = "[A]I: Switch Provider" },
    { "<leader>ar", "<cmd>AvanteRefresh<cr>",        desc = "[A]I: Refresh Windows" },
  },
  ---@module 'avante'
  ---@type avante.Config
  opts = {
    provider = "openai",
    providers = {
      openai = {
        endpoint = "https://api.openai.com/v1",
        model = "gpt-4o-mini",
      },
    },
    behaviour = {
      auto_suggestions = true, -- inline, experimental
    },
    prompt_logger = {
      log_dir = vim.fn.stdpath("cache") .. "/avante_prompts",
    },
    input = {
      provider = "snacks",
      provider_opts = {
        title = "Avante Input",
        icon = " ",
      },
    },

    -- "agentic" enables tool execution
    -- "legacy" just gives text suggestions
    mode = "legacy",

    windows = {
      position = "right",
      width = 30,
      sidebar_header = { enabled = true },
      input = {
        prefix = "> ",
        height = 8,
      },
      ask = {
        border = "rounded",
        floating = false,
      },
    },
    rules = {
      project_dir = ".avante/rules",         -- relative to project root, can also be an absolute path
      global_dir = "~/.config/avante/rules", -- absolute path
    },
  },
}
