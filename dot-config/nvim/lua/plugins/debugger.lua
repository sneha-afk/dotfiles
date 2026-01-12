-- .config/nvim/lua/plugins/debugger.lua

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
      },
      "williamboman/mason.nvim",
    },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "[D]ebug: Toggle [B]reakpoint" },
      { "<leader>dc", function() require("dap").continue() end,          desc = "[D]ebug: [C]ontinue" },
      { "<leader>di", function() require("dap").step_into() end,         desc = "[D]ebug: Step [I]nto" },
      { "<leader>do", function() require("dap").step_over() end,         desc = "[D]ebug: Step [O]ver" },
      { "<leader>du", function() require("dapui").toggle() end,          desc = "[D]ebug: Toggle [U]I" },
      { "<leader>dr", function() require("dap").repl.toggle() end,       desc = "[D]ebug: Toggle [R]EPL" },
      { "<leader>dT", function() require("dap").terminate() end,         desc = "[D]ebug: [T]erminate" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()

      -- Auto open/close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped",    { text = "▶", texthl = "DapStopped", linehl = "Visual", numhl = "" })
    end,

  },
}
