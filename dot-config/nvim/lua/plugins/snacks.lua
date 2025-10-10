-- .config/nvim/lua/plugins/snacks.lua

return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 1000,
  dependencies = { "nvim-mini/mini.diff" },
  keys = {
    { "<leader>hn", function() Snacks.notifier.show_history() end,         desc = "[H]istory: [N]otifications" },
    { "<leader>.",  function() Snacks.scratch() end,                       desc = "Toggle scratch buffer" },
    { "<leader>sb", function() Snacks.scratch.select() end,                desc = "Select: [s]cratch [b]uffer" },

    -- Buffers
    { "<leader>fb", function() Snacks.picker.lines() end,                  desc = "[F]ind: within [B]uffer" },
    { "<leader>fB", function() Snacks.picker.buffers() end,                desc = "[F]ind: open [B]uffers" },
    { "<leader>fd", function() Snacks.picker.diagnostics_buffer() end,     desc = "[F]ile: [D]iagnostics" },

    -- Commands
    { "<leader>fc", function() Snacks.picker.commands() end,               desc = "[F]ind: [C]ommands" },
    { "<leader>fC", function() Snacks.picker.command_history() end,        desc = "[F]ind: [C]ommand History" },

    -- Files
    { "<leader>fe", function() Snacks.explorer({ auto_close = true }) end, desc = "[F]ile: [E]xplorer" },
    { "<leader>ff", require("core.utils.fileops").snacks_find_files,       desc = "[F]ind: [F]iles" },
    { "<leader>fg", function() Snacks.picker.grep() end,                   desc = "[F]ind: live [G]rep" },
    { "<leader>fm", function() Snacks.picker.marks() end,                  desc = "[F]ind: [M]arks" },
    { "<leader>fr", function() Snacks.picker.recent() end,                 desc = "[F]ind: [R]ecent files" },
    { "<leader>fs", function() Snacks.picker.smart() end,                  desc = "[F]ind: [S]mart" },

    -- Searching
    { "<leader>sh", function() Snacks.picker.search_history() end,         desc = "[S]earch: [H]istory" },
    { "<leader>sH", function() Snacks.picker.help() end,                   desc = "[S]earch: [H]elp tags" },
    { "<leader>sk", function() Snacks.picker.keymaps() end,                desc = "[S]earch: [K]eymaps" },
    { "<leader>sM", function() Snacks.picker.man() end,                    desc = "[S]earch: [M]an pages" },
    { "<leader>sp", function() Snacks.picker.pickers() end,                desc = "[S]earch: [P]ickers" },

    -- LSP operations
    { "gd",         function() Snacks.picker.lsp_definitions() end,        desc = "Goto Definition" },
    { "gD",         function() Snacks.picker.lsp_declarations() end,       desc = "Goto Declaration" },
    { "gR",         function() Snacks.picker.lsp_references() end,         desc = "Goto references",           nowait = true },
    { "gi",         function() Snacks.picker.lsp_implementations() end,    desc = "Goto Implementation" },
    { "gy",         function() Snacks.picker.lsp_type_definitions() end,   desc = "Goto T[y]pe Definition" },
    { "<leader>lc", function() Snacks.picker.lsp_config() end,             desc = "[L]SP: [C]onfig" },
    { "<leader>ls", function() Snacks.picker.lsp_symbols() end,            desc = "[L]SP: document [S]ymbols" },
    { "<leader>lS", function() Snacks.picker.lsp_workspace_symbols() end,  desc = "[L]SP: workspace [S]ymbols" },

    -- Git operations
    { "<leader>gb", function() Snacks.picker.git_branches() end,           desc = "[G]it: [B]ranches" },
    { "<leader>gD", function() Snacks.picker.git_diff() end,               desc = "[G]it: [D]iff (Overview)" },
    { "<leader>gl", function() Snacks.picker.git_log() end,                desc = "[G]it: Log" },
    { "<leader>gs", function() Snacks.picker.git_status() end,             desc = "[G]it: [S]tatus" },
    { "<leader>gS", function() Snacks.picker.git_stash() end,              desc = "[G]it: [S]tash" },
    { "<leader>go", function() Snacks.gitbrowse() end,                     desc = "[G]it: [O]pen in browser" },

  },
  ---@module "snacks"
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    gitbrowse = { enabled = true },
    indent = {
      enabled = true,
      animate = { enabled = false },
      chunk = {
        enabled = true,
        char = {
          corner_top = "╭",
          corner_bottom = "╰",
          horizontal = "─",
          vertical = "│",
          arrow = "🞂",
        },
        hl = require("core.utils.ui").color_cycle,
      },
      scope = {
        hl = require("core.utils.ui").color_cycle,
      },
    },
    input = {
      enabled = true,
      icon = " ",
    },
    picker = {
      enabled = true,
      icons = {
        kinds = require("core.utils.ui").get_icon_set(),
      },
      layout = {
        layout = {
          max_width = math.floor(vim.o.columns / 1.05),
          max_height = math.floor(vim.o.lines / 1.05),
          height = 0.85,
        },
      },
    },
    scope = { enabled = true },
    scratch = {
      enabled = true,
      icon = "⚏",
    },
    statuscolumn = {
      enabled = true,
      fold = { open = true },
    },
    toggle = {
      enabled = true,
      icon = {
        enabled = "●",
        disabled = "○",
      },
    },
    zen = {
      enabled = true,
      on_open = function(win)
        vim.cmd("set nu!")
      end,
    },
    notifier = {
      timeout = 3000,   -- in ms
      top_down = false, -- false for bottom up
      icons = {
        error = "[E] ",
        warn = "[W] ",
        info = "[I] ",
        debug = "[D] ",
        trace = "[T] ",
      },
    },
    styles = {
      input = {
        relative = "cursor",
        position = "float",
      },
      notification_history = {
        width = 0.85,
        height = 0.75,
        relative = "editor",
      },
      scratch = {
        width = 0.85,
        height = 0.75,
        relative = "editor",
      },
      zen = {
        relative = "editor",
        width = 0.75,
        backdrop = {
          transparent = true,
          blend = 15,
        },
      },
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        Snacks.toggle.indent():map("<leader>ui")
        Snacks.toggle.zen():map("<leader>uz")
      end,
    })
  end,
}
