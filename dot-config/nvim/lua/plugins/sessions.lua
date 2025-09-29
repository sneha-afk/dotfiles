return {
  "nvim-mini/mini.sessions",
  event = { "BufReadPre", "BufNewFile" },
  version = false,
  config = function()
    local sessions = require("mini.sessions")
    sessions.setup({
      autoread = false,
      autowrite = true,
      directory = vim.fn.stdpath("state") .. "/sessions/",
    })

    vim.keymap.set("n", "<leader>sw", function()
      local ok, _ = pcall(sessions.write)
      if ok then return end

      -- Prompt user for session name if initial write failed
      vim.ui.input({ prompt = "Session name (required): " }, function(name)
        if not name or name == "" then
          vim.notify("Session write cancelled: no name provided", vim.log.levels.WARN)
          return
        end
        sessions.write(name)
      end)
    end, { desc = "[S]ession: [W]rite" })
    vim.keymap.set("n", "<leader>sl", sessions.select, { desc = "[S]ession: [L]oad" })
  end,
}
