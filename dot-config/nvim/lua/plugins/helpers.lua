-- ./config/nvim/lua/plugins/helpers.lua
-- Helpful utilities

local colorizer_fts = { "css", "scss", "sass", "less", "html" }

return {
  {
    "nvim-mini/mini.pairs",
    event = "InsertEnter",
    version = false,
    config = true,
  },
  {
    "nvim-mini/mini.surround",
    event = "ModeChanged *:[vV\x16]*", -- Load on Visual
    version = false,
    config = true,
  },
  {
    "norcalli/nvim-colorizer.lua",
    cmd = { "ColorizerAttachToBuffer", "ColorizerToggle" },
    ft = colorizer_fts,
    opts = {
      "*", -- Highlight all filetypes with default opts
      css = { rgb_fn = true },
      scss = { rgb_fn = true },
      sass = { rgb_fn = true },
    },
    config = function(_, opts)
      local colorizer = require("colorizer")
      colorizer.setup(opts)

      vim.api.nvim_create_autocmd("FileType", {
        pattern = colorizer_fts,
        callback = function(args)
          colorizer.attach_to_buffer(args.buf)
        end,
      })
    end,
  },
  {
    "brianhuster/live-preview.nvim",
    cmd = { "LivePreview", "LivePreviewPortChange" },
    dependencies = { vim.g.picker_source },
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
  },
  {
    "folke/todo-comments.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>st", function() Snacks.picker.todo_comments() end, desc = "[S]earch: ToDo" },
      {
        "<leader>sT",
        function()
          Snacks.picker.todo_comments({
            keywords = { "TODO", "FIX", "FIXME", "HACK" },
          })
        end,
        desc = "[S]earch: ToDo/Fix",
      },
    },
    dependencies = {
      -- "nvim-lua/plenary.nvim", -- not needed if using a picker?
      vim.g.picker_source,
    },
    opts = {
      keywords = {
        FIX = { icon = "F " },
        TODO = { icon = "T " },
        HACK = { icon = "! " },
        WARN = { icon = "W " },
        PERF = { icon = "P " },
        NOTE = { icon = "N " },
        TEST = { icon = "⏵" },
      },
    },
  },
}
