-- .config/lua/plugins/neotest.lua

local neotest_icons = vim.g.use_icons and {
  child_indent       = "│",
  child_prefix       = "├",
  collapsed          = "─",
  expanded           = "╮",
  failed             = "",
  final_child_indent = " ",
  final_child_prefix = "╰",
  non_collapsible    = "─",
  notify             = "",
  passed             = "",
  running            = "",
  running_animated   = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
  skipped            = "",
  test               = "",
  unknown            = "",
  watching           = "",
} or {
  child_indent       = "│",
  child_prefix       = "├",
  collapsed          = "─",
  expanded           = "╮",
  failed             = "✗",
  final_child_indent = " ",
  final_child_prefix = "╰",
  non_collapsible    = "─",
  notify             = "⌬",
  passed             = "✓",
  running            = "→",
  running_animated   = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
  skipped            = "○",
  test               = "⌬",
  unknown            = "?",
  watching           = "~",
}

return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "stevearc/overseer.nvim",
    "fredrikaverpil/neotest-golang",
  },
  keys = {
    { "<leader>Tn", function() require("neotest").run.run() end,                     desc = "[T]est: run [N]earest" },
    { "<leader>Ta", function() require("neotest").run.attach() end,                  desc = "[T]est: [A]ttach" },
    { "<leader>TA", function() require("neotest").run.run(vim.uv.cwd()) end,         desc = "[T]est: run [A]ll" },
    { "<leader>Td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "[T]est: run with [D]AP" },
    {
      "<leader>Tf",
      function() require("neotest").run.run(vim.api.nvim_buf_get_name(0)) end,
      desc = "[T]est: run [F]ile",
    },
    {
      "<leader>TF",
      function()
        require("neotest").output.open({ enter = true, last_run = true })
      end,
      desc = "[T]est: open last [F]ailure",
    },
    { "<leader>Ts", function() require("neotest").run.run({ suite = true }) end,     desc = "[T]est: run [S]uite" },
    { "<leader>TS", function() require("neotest").run.stop() end,                    desc = "[T]est: [S]top" },
    { "<leader>Tt", function() require("neotest").summary.toggle() end,              desc = "[T]est: [T]est summary" },
    { "<leader>To", function() require("neotest").output.open({ enter = true }) end, desc = "[T]est: [O]utput" },
    { "<leader>Tp", function() require("neotest").output_panel.toggle() end,         desc = "[T]est: [P]anel" },
    { "<leader>TL", function() require("neotest").run.run_last() end,                desc = "[T]est: run [L]ast" },
    {
      "<leader>Tw",
      function()
        require("neotest").watch.toggle(vim.api.nvim_buf_get_name(0))
      end,
      desc = "[T]est: [W]atch file",
    },
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-golang")({
          go_test_args = {
            "-v",
            "-race",
            "-count=1",
            "-timeout=60s",
          },
          dap_go_enabled = true,
        }),
      },
      consumers = {
        overseer = require("neotest.consumers.overseer"),
      },
      icons = neotest_icons,
      output = {
        open_on_run = false,
      },
    })
  end,
}
