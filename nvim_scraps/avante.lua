-- .config/nvim/lua/plugins/avante.lua
-- AI completion through API keys
-- See: https://github.com/yetone/avante.nvim

-- Important: toggle used in completion setup
vim.g.enable_avante = false

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
    "nvim-mini/mini.icons",
    -- render-markdown.nvim setup elsewhere
  },
  keys = {
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
    selector = {
      --- @type avante.SelectorProvider
      provider = "snacks",
    },
    input = {
      provider = "snacks",
      provider_opts = {
        title = "Avante Input",
      },
    },
    mappings = {
      suggestion = { -- WezTerm uses M(A)-l
        accept = "<C-l>",
        next = "<M-]>",
        prev = "<M-[>",
        dismiss = "<C-]>",
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
