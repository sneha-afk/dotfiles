-- .config/nvim/lua/plugins

return {
  "brianhuster/live-preview.nvim",
  event = { "VeryLazy" },
  dependencies = { "nvim-telescope/telescope.nvim" },
  opts = {
    port = 8000,
  },
  config = function(_, opts)
    require("livepreview.config").set(opts)

    vim.api.nvim_create_user_command("LivePreviewPortChange", function(_)
      vim.ui.input({
        prompt = "Set LivePreview Port: ",
        default = "8000",
        kind = "panel",
      }, function(input)
        if not input then return end

        local port = tonumber(input)
        if not port then
          vim.notify("Invalid port number", vim.log.levels.ERROR)
          return
        end

        if port < 1024 or port > 49151 then
          vim.notify("Port must be between 1024-49151", vim.log.levels.ERROR)
          return
        end

        vim.cmd("lua LivePreview.config.port =" .. port)
        vim.notify(string.format("LivePreview port set to %d", port), vim.log.levels.INFO)
      end)
    end, {
      desc = "Set the port for LivePreview server",
      nargs = "?",
    })
  end,
}
