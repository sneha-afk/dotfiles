-- ./config/nvim/lua/plugins/helpers.lua
-- Helpful utilities

return {
  {
    "nvim-mini/mini.surround",
    event = "ModeChanged *:[vV\x16]*", -- Load on Visual
    version = false,
    config = true,
  },
  {
    "saghen/blink.pairs",
    event = "InsertEnter",
    version = "*",
    dependencies = "saghen/blink.download",
    --- @module 'blink.pairs'
    --- @type blink.pairs.Config
    opts = {
      highlights = {
        enabled = true,
        groups = require("utils.ui").color_cycle,
        matchparen = { enabled = true },
      },
    },
  },
  {
    "norcalli/nvim-colorizer.lua",
    cmd = { "ColorizerAttachToBuffer", "ColorizerToggle" },
    ft = { "css", "scss", "sass", "less", "html" },
    opts = {
      "*", -- Highlight all filetypes with default opts
      css = { rgb_fn = true },
      scss = { rgb_fn = true },
      sass = { rgb_fn = true },
    },
  },
  {
    "brianhuster/live-preview.nvim",
    cmd = { "LivePreview", "LivePreviewPortChange" },
    dependencies = { vim.g.picker_source },
    opts = {
      port = 5500,
    },
    config = function(_, opts)
      require("livepreview.config").set(opts)

      vim.api.nvim_create_user_command("LivePreviewPortChange", function(_)
        vim.ui.input({
          prompt = "Set LivePreview Port: ",
          default = "5500",
          kind = "panel",
        }, function(input)
          if not input then return end

          local port = tonumber(input)
          if not port then
            vim.notify("Invalid port number", vim.log.levels.ERROR)
            return
          end

          if port < 1024 or port > 65535 then
            vim.notify("Port must be between 1024-65535", vim.log.levels.ERROR)
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
    event = { "BufReadPost", "BufNewFile" },
    keys = {
      { "<leader>ft", function() Snacks.picker.todo_comments() end, desc = "[F]ind: ToDos" },
      {
        "<leader>fT",
        function()
          Snacks.picker.todo_comments({
            keywords = { "TODO", "FIX", "FIXME", "HACK" },
          })
        end,
        desc = "[F]ind: ToDos/Fix",
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
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {},
    keys = {
      { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
      { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
      { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
      { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<A-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>gd", "<cmd>Gitsigns toggle_linehl<cr>", desc = "[G]it: toggle [D]iff Overlay" },
    },
    opts = {
      signs = {
        add          = { text = "┃" },
        change       = { text = "┇" },
        delete       = { text = "━" },
        topdelete    = { text = "━" },
        changedelete = { text = "┇" },
        untracked    = { text = "┃" },
      },
      signs_staged = {
        add          = { text = "┃" },
        change       = { text = "┇" },
        delete       = { text = "━" },
        topdelete    = { text = "━" },
        changedelete = { text = "┇" },
        untracked    = { text = "┃" },
      },
      numhl = false,
      linehl = false,
      word_diff = false,
      preview_config = {
        border = "rounded",
        style = "minimal",
        relative = "cursor",
      },
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gitsigns.nav_hunk("next")
          end
        end, { desc = "[G]it: next [C]hange (hunk)" })

        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gitsigns.nav_hunk("prev")
          end
        end, { desc = "[G]it: prev [C]hange (hunk)" })

        -- Hunk actions
        map("n", "ghs", gitsigns.stage_hunk, { desc = "[G]it [H]unk: Toggle [S]tage" })
        map("n", "ghr", gitsigns.reset_hunk, { desc = "[G]it [H]unk: [R]eset" })
        map("v", "ghs", function()
          gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "[G]it [H]unk: [S]tage selection" })
        map("v", "ghr", function()
          gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "[G]it [H]unk: [R]eset selection" })

        map("n", "ghS", gitsigns.stage_buffer,        { desc = "[G]it [H]unk: [S]tage buffer" })
        map("n", "ghR", gitsigns.reset_buffer,        { desc = "[G]it [H]unk: [R]eset buffer" })

        map("n", "ghp", gitsigns.preview_hunk,        { desc = "[G]it [H]unk: [P]review" })
        map("n", "ghi", gitsigns.preview_hunk_inline, { desc = "[G]it [H]unk: preview [I]nline" })

        map("n", "ghb", function()
          gitsigns.blame_line({ full = true })
        end, { desc = "[G]it [H]unk: [B]lame line" })

        map("n", "ghd", gitsigns.diffthis,                     { desc = "[G]it [H]unk: [D]iff buffer" })
        map("n", "ghD", function() gitsigns.diffthis("~") end, { desc = "[G]it [H]unk: [D]iff vs last commit" })

        map("n", "ghQ", function() gitsigns.setqflist("all") end,
          { desc = "[G]it [H]unk: populate [Q]uickfix (all)" })

        map("n", "ghq", gitsigns.setqflist, {
          desc = "[G]it [H]unk: populate [Q]uickfix (buffer)" })

        map({ "o", "x" }, "ih", gitsigns.select_hunk, { desc = "Select Git [H]unk" })
      end,
    },
    config = function(_, opts)
      local gitsigns = require("gitsigns")
      gitsigns.setup(opts)

      local hl = vim.api.nvim_set_hl
      hl(0, "GitSignsAdd",          { link = "DiffAdd" })
      hl(0, "GitSignsChange",       { link = "DiffChange" })
      hl(0, "GitSignsDelete",       { link = "DiffDelete" })
      hl(0, "GitSignsChangedelete", { link = "DiffChange" })
      hl(0, "GitSignsTopdelete",    { link = "DiffDelete" })
      hl(0, "GitSignsUntracked",    { link = "Comment" })
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    lazy = true,
    enabled = vim.g.use_icons,
    ft = { "markdown", "Avante" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.icons" },
    ---@module "render-markdown"
    ---@type render.md.UserConfig
    opts = {
      file_types = { "markdown", "Avante" },
      heading = {
        icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " },
      },
    },
  },
  {
    "stevearc/overseer.nvim",
    cmd = { "OverseerToggle", "OverseerRun", "OverseerShell" },
    ---@module 'overseer'
    ---@type overseer.SetupOpts
    opts = {},
    config = function(_, opts)
      local overseer = require("overseer")
      overseer.setup(opts)

      vim.api.nvim_create_user_command("OverseerRestartLast", function()
        local task_list = require("overseer.task_list")
        local tasks = overseer.list_tasks({
          status = {
            overseer.STATUS.SUCCESS,
            overseer.STATUS.FAILURE,
            overseer.STATUS.CANCELED,
          },
          sort = task_list.sort_finished_recently,
        })
        if vim.tbl_isempty(tasks) then
          vim.notify("No tasks found", vim.log.levels.WARN)
        else
          local most_recent = tasks[1]
          overseer.run_action(most_recent, "restart")
        end
      end, {})

      vim.api.nvim_create_user_command("OverseerSeeLastOutput",
        function()
          overseer.create_task_output_view(0, {
            list_task_opts = {
              filter = function(task)
                return task.time_start ~= nil
              end,
            },
            select = function(self, tasks, task_under_cursor)
              table.sort(tasks, function(a, b)
                return a.time_start > b.time_start
              end)
              return tasks[1]
            end,
          })
        end, {
          desc = "See output of the most recently run task",
          nargs = "*",
          bang = true,
        })
    end,
  },
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = "TermSelect",
    keys = {
      { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>",      desc = "[T]erminal: [F]loat" },
      { "<leader>ht", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "[H]orizontal [T]erminal" },
      { "<leader>vt", "<cmd>ToggleTerm direction=vertical<cr>",   desc = "[V]ertical [T]erminal" },
      { "<leader>tt", "<cmd>ToggleTerm direction=tab<cr>",        desc = "[T]erminal: [T]ab" },
    },
    opts = {
      open_mapping = [[<c-\>]],
      direction = "float",
      float_opts = {
        border = "rounded",
        title_pos = "center",
      },
      highlights = {
        FloatBorder = { link = "FloatBorder" },
        NormalFloat = { link = "NormalFloat" },
      },
    },
  },
  {
    "ojroques/nvim-osc52",
    enabled = function()
      return vim.env.SSH_CONNECTION ~= nil or vim.env.SSH_CLIENT ~= nil
    end,
    event = "VeryLazy",
    config = function()
      -- https://github.com/ojroques/nvim-osc52?tab=readme-ov-file#using-nvim-osc52-as-clipboard-provider
      local function copy(lines, _)
        require("osc52").copy(table.concat(lines, "\n"))
      end

      local function paste()
        return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
      end

      vim.g.clipboard = {
        name = "osc52",
        copy = { ["+"] = copy, ["*"] = copy },
        paste = { ["+"] = paste, ["*"] = paste },
      }
    end,
  },

}
