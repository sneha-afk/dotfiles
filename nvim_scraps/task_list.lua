-- ./config/nvim/lua/plugins/task_list.lua

return {
  {
    "Hashino/doing.nvim",
    event = "VeryLazy",
    cmd = { "Do", "Done" },
    keys = {
      { "<leader>Da", function() require("doing").add() end,    desc = "[D]oing: [A]dd note" },
      { "<leader>Dd", function() require("doing").done() end,   desc = "[D]oing: mark [D]one" },
      { "<leader>De", function() require("doing").edit() end,   desc = "[D]oing: [E]dit" },
      { "<leader>Dt", function() require("doing").toggle() end, desc = "[D]oing: [T]oggle" },
      {
        "<leader>Ds",
        function()
          vim.notify(require("doing").status(true), vim.log.levels.INFO, { title = "Doing:", icon = "☰" })
        end,
        desc = "[D]oing: [S]tatus",
      },
    },
    opts = {
      store = {
        file_name = ".tasks",
        sync_tasks = true,
      },
    },
    init = function(_, opts)
      local doing = require("doing")
      doing.setup(opts)

      vim.api.nvim_create_autocmd({ "User" }, {
        pattern = "TaskModified",
        desc = "This is called when a task is added, edited or completed",
        callback = function()
          vim.defer_fn(function()
                         local status = doing.status()
                         if status ~= "" then
                           vim.notify(status, vim.log.levels.INFO, { title = "Doing:", icon = "☰" })
                         end
                       end, 0)
        end,
      })
    end,
  },
}