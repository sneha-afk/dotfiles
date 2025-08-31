-- .config/nvim/lua/plugins/sessions.lua

return {
  "folke/persistence.nvim",
  enabled = false,
  event = "BufReadPre",
  keys = {
    { "<leader>sl", function() require("persistence").select() end,              desc = "[S]essions: [L]oad session" },
    { "<leader>sL", function() require("persistence").load({ last = true }) end, desc = "[S]essions: [L]oad last" },
    { "<leader>sS", function() require("persistence").stop() end,                desc = "[S]essions: [S]top current" },
    { "<leader>sd", "<cmd>DeleteSession<cr>",                                    desc = "[S]essions: [d]elete session" },
    { "<leader>sD", "<cmd>DeleteAllSessions<cr>",                                desc = "[S]essions: [D]elete all" },
  },
  opts = {
    dir = vim.fn.stdpath("state") .. "/sessions/",
    -- branch = not vim.g.is_windows,
  },
  config = function(_, opts)
    local ft = vim.bo.filetype
    if ft == "tex" or ft == "bib" then
      return
    end

    local persistence = require("persistence")
    persistence.setup(opts)

    local sessions_dir = opts.dir

    ---@return table|nil Filepaths of previous sessions
    local function get_sessions()
      local sessions = vim.fn.glob(sessions_dir .. "*.vim", false, true)
      if #sessions == 0 then
        vim.notify("No sessions found", vim.log.levels.INFO)
        return nil
      end
      return sessions
    end

    ---Truncates home directory to ~, removes *.vim extension
    ---@param path string Filepath of a session
    ---@return string Standardized sessions path
    local function format_session_path(path)
      local standard, _ = path
          :gsub("^" .. vim.pesc(sessions_dir), "") -- Remove session directory
          :gsub("%%", "/")                         -- Convert URL-encoded % to /
          :gsub("%.vim$", "")                      -- Remove .vim extension
      local time = os.date("%Y-%m-%d %I:%M %P", vim.fn.getftime(path))
      return string.format("%s | %s", time, vim.fn.fnamemodify(standard, ":~"))
    end

    ---Deletes the specified sessions
    ---@param session_path string
    local function delete_session(session_path)
      local deleted, failed = 0, 0
      if os.remove(session_path) then
        deleted = deleted + 1
      else
        failed = failed + 1
        vim.notify("Failed to delete: " .. session_path, vim.log.levels.ERROR)
      end
      vim.notify(
        string.format("Deleted %d session(s)%s", deleted, failed > 0 and (" (%d failed)"):format(failed) or ""),
        vim.log.levels.INFO
      )
    end

    -- Select one session from vim.ui.select
    vim.api.nvim_create_user_command("DeleteSession", function()
      local sessions = get_sessions()
      if not sessions then return end

      local session_names = vim.tbl_map(format_session_path, sessions)
      vim.ui.select(session_names,
        {
          prompt = "Select session to delete:",
        },
        function(choice, idx)
          if choice and idx then delete_session(sessions[idx]) end
        end
      )
    end, { desc = "Delete a section selected by user" })

    -- Delete all sessions
    vim.api.nvim_create_user_command("DeleteAllSessions", function()
      local sessions = get_sessions()
      if not sessions then return end

      local session_names = vim.tbl_map(format_session_path, sessions)
      vim.notify("Found sessions:\n" .. table.concat(session_names, "\n"), vim.log.levels.INFO)

      local choice = vim.fn.confirm(
        string.format("Delete ALL %d sessions?", #sessions),
        "&No\n&Yes",
        1, -- Default to No
        "Question"
      )
      if choice == 2 then -- Yes
        local deleted = 0
        for _, file in ipairs(sessions) do
          if os.remove(file) then deleted = deleted + 1 end
        end
        vim.notify(
          string.format("Deleted %d/%d sessions", deleted, #sessions),
          deleted > 0 and vim.log.levels.INFO or vim.log.levels.ERROR
        )
      end
    end, { desc = "Delete all sessions with confirmation" })
  end,
}
