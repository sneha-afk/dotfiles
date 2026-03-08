-- .config/nvim/lua/plugins/sessions.lua

return {
  "folke/persistence.nvim",
  event = "BufReadPre",
  keys = {
    { "<leader>sl", function() require("persistence").select() end,              desc = "[S]essions: [L]oad session" },
    { "<leader>sL", function() require("persistence").load({ last = true }) end, desc = "[S]essions: [L]oad last" },
    { "<leader>sS", function() require("persistence").stop() end,                desc = "[S]essions: [S]top current" },
    { "<leader>sd", "<cmd>DeleteSession<cr>",                                    desc = "[S]essions: [d]elete session" },
    { "<leader>sD", "<cmd>DeleteAllSessions<cr>",                                desc = "[S]essions: [D]elete all" },
  },
  cmd = { "DeleteSession", "DeleteAllSessions" },
  ---@module "persistence"
  ---@type Persistence.Config
  opts = {
    dir = vim.fn.stdpath("state") .. "/sessions/",
  },
  config = function(_, opts)
    local persistence = require("persistence")
    persistence.setup(opts)

    ---@type string
    local sessions_dir = opts.dir
    local original_cwd = nil

    -- Change to Git root or CWD before saving session
    vim.api.nvim_create_autocmd("User", {
      pattern = "PersistenceSavePre",
      callback = function()
        original_cwd = vim.uv.cwd() or vim.fn.getcwd()

        local git_root = require("utils.paths").start_search_path()
        if git_root and git_root ~= "" then
          vim.fn.chdir(git_root)
        end
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "PersistenceSavePost",
      callback = function()
        if original_cwd then
          vim.fn.chdir(original_cwd)
          original_cwd = nil
        end
      end,
    })

    ---Return session filepaths
    ---@return string[]|nil
    local function get_sessions()
      local sessions = vim.fn.glob(sessions_dir .. "*.vim", false, true)
      if vim.tbl_isempty(sessions) then
        vim.notify("No sessions found", vim.log.levels.INFO)
        return nil
      end
      return sessions
    end

    ---Truncates home directory to ~, removes *.vim extension
    ---@param path string Filepath of a session
    ---@return string Standardized sessions path
    local function format_session_path(path)
      local name = path
          :gsub("^" .. vim.pesc(sessions_dir), "") -- Remove session directory
          :gsub("%%", "/")                         -- Convert URL-encoded % to /
          :gsub("%.vim$", "")                      -- Remove .vim extension

      ---@type string[]
      local parts = vim.split(name, "/", { trimempty = true })

      local tail
      if #parts <= 3 then
        tail = table.concat(parts, "/")
      else
        tail = "…/" .. table.concat(parts, "/", #parts - 2)
      end

      local time = os.date("%Y-%m-%d %I:%M %p", vim.fn.getftime(path))
      return ("%s | %s"):format(time, tail)
    end

    ---Delete a session file
    ---@param path string
    ---@return boolean success
    local function delete_session(path)
      local ok = os.remove(path)
      if ok then
        vim.notify("Deleted session: " .. vim.fn.fnamemodify(path, ":t"))
      else
        vim.notify("Failed to delete: " .. path, vim.log.levels.ERROR)
      end
      return ok
    end

    vim.api.nvim_create_user_command("DeleteSession", function()
      local sessions = get_sessions()
      if not sessions then return end

      vim.ui.select(
        vim.tbl_map(format_session_path, sessions),
        { prompt = "Select session to delete:" },
        ---@param _ string|nil
        ---@param idx integer|nil
        function(_, idx)
          if idx then delete_session(sessions[idx]) end
        end
      )
    end, { desc = "Delete a session selected by user" })

    vim.api.nvim_create_user_command("DeleteAllSessions", function()
      local sessions = get_sessions()
      if not sessions then return end

      local confirm = vim.fn.confirm(
        ("Delete ALL %d sessions?"):format(#sessions),
        "&No\n&Yes",
        1 -- default: no
      )
      if confirm ~= 2 then return end

      local deleted = 0
      for _, file in ipairs(sessions) do
        if delete_session(file) then deleted = deleted + 1 end
      end

      vim.notify(("Deleted %d/%d sessions"):format(deleted, #sessions),
        deleted > 0 and vim.log.levels.INFO or vim.log.levels.ERROR
      )
    end, { desc = "Delete all sessions" })
  end,
}
