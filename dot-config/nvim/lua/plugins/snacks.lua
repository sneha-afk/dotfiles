-- .config/nvim/lua/plugins/snacks.lua

local fileopts = require("utils.fileops")
local ui_utils = require("utils.ui")

local prompt_icon = vim.g.use_icons and " " or "> "

local function get_greeting()
  local hour = tonumber(os.date("%H"))
  local greetings = {
    { max = 5, msg = "Sleep well", emoji = "🌙" },
    { max = 12, msg = "Good morning", emoji = "🌅" },
    { max = 18, msg = "Good afternoon", emoji = "🌞" },
    { max = 22, msg = "Good evening", emoji = "🌆" },
    { max = 24, msg = "Good night", emoji = "✨" },
  }

  for _, greeting in ipairs(greetings) do
    if hour < greeting.max then return greeting.emoji .. " " .. greeting.msg end
  end
  return "Hello"
end

local function get_footer()
  local version = vim.version()
  local nvim_version = string.format("NVIM v%d.%d.%d", version.major, version.minor, version.patch)
  local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":~")

  return string.format("%s • %s\n%s", os.date("%A, %B %d %Y • %I:%M %p"), nvim_version, cwd)
end

local explorer_sidebar = function()
  Snacks.explorer({
    layout = { preset = "sidebar", layout = { position = "right", width = 0.25 } },
    cwd = Snacks.git.get_root() or vim.uv.cwd(),
    auto_close = false,
  })
end

local explorer_fullscreen = function()
  Snacks.explorer({
    layout = { preset = "default", layout = { width = 0.95 } },
    cwd = Snacks.git.get_root() or vim.uv.cwd(),
  })
end

return {
  "folke/snacks.nvim",
  lazy = false,
  priority = 1000,
  dependencies = {
    "nvim-mini/mini.icons",
  },
  keys = {
    { "<leader>fe", explorer_sidebar,                     desc = "[F]ile: [E]xplorer" },
    { "<leader>fE", explorer_fullscreen,                  desc = "[F]ile: [E]xplorer (fullscreen)" },
    { "<leader>ff", function() Snacks.picker.files() end, desc = "[F]ind: [F]iles" },
    {
      "<leader>tf",
      function() Snacks.terminal.toggle(nil, { win = { position = "float" } }) end,
      desc = "[T]erminal: toggle [F]loating",
    },

    { "<leader>hn", function() Snacks.notifier.show_history() end,        desc = "[H]istory: [N]otifications" },
    { "<leader>.",  function() Snacks.scratch() end,                      desc = "Toggle scratch buffer" },
    { "<leader>sb", function() Snacks.scratch.select() end,               desc = "Select: [s]cratch [b]uffer" },

    { "<leader>fb", function() Snacks.picker.lines() end,                 desc = "[F]ind: within [B]uffer" },
    { "<leader>fB", function() Snacks.picker.buffers() end,               desc = "[F]ind: open [B]uffers" },
    { "<leader>fd", function() Snacks.picker.diagnostics_buffer() end,    desc = "[F]ile: [D]iagnostics" },
    { "<leader>fD", function() Snacks.picker.diagnostics() end,           desc = "[F]ile: [D]iagnostics (CWD)" },

    { "<leader>fc", function() Snacks.picker.commands() end,              desc = "[F]ind: [C]ommands" },
    { "<leader>fC", function() Snacks.picker.command_history() end,       desc = "[F]ind: [C]ommand History" },

    { "<leader>fg", function() Snacks.picker.grep() end,                  desc = "[F]ind: live [G]rep" },
    { "<leader>fm", function() Snacks.picker.marks() end,                 desc = "[F]ind: [M]arks" },
    { "<leader>fp", function() Snacks.picker.projects() end,              desc = "[F]ind: [P]rojects" },
    { "<leader>fr", function() Snacks.picker.recent() end,                desc = "[F]ind: [R]ecent files" },
    { "<leader>fs", function() Snacks.picker.smart() end,                 desc = "[F]ind: [S]mart" },

    { "<leader>sh", function() Snacks.picker.search_history() end,        desc = "[S]earch: [H]istory" },
    { "<leader>sH", function() Snacks.picker.help() end,                  desc = "[S]earch: [H]elp tags" },
    { "<leader>sk", function() Snacks.picker.keymaps() end,               desc = "[S]earch: [K]eymaps" },
    { "<leader>sM", function() Snacks.picker.man() end,                   desc = "[S]earch: [M]an pages" },
    { "<leader>sP", function() Snacks.picker.pickers() end,               desc = "[S]earch: [P]ickers" },
    { "<leader>sq", function() Snacks.picker.qflist() end,                desc = "[S]earch: [Q]uickfix List" },

    -- LSP operations
    { "gd",         function() Snacks.picker.lsp_definitions() end,       desc = "Goto Definition" },
    { "gD",         function() Snacks.picker.lsp_declarations() end,      desc = "Goto Declaration" },
    { "gR",         function() Snacks.picker.lsp_references() end,        desc = "Goto references",            nowait = true },
    { "gi",         function() Snacks.picker.lsp_implementations() end,   desc = "Goto Implementation" },
    { "gy",         function() Snacks.picker.lsp_type_definitions() end,  desc = "Goto T[y]pe Definition" },
    { "gI",         function() Snacks.picker.lsp_incoming_calls() end,    desc = "Goto [I]ncoming Calls" },
    { "gO",         function() Snacks.picker.lsp_outgoing_calls() end,    desc = "Goto [O]utgoing Calls" },
    { "<leader>lc", function() Snacks.picker.lsp_config() end,            desc = "[L]SP: [C]onfig" },
    { "<leader>ls", function() Snacks.picker.lsp_symbols() end,           desc = "[L]SP: document [S]ymbols" },
    { "<leader>lS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "[L]SP: workspace [S]ymbols" },

    -- Git operations
    { "<leader>gb", function() Snacks.picker.git_branches() end,          desc = "[G]it: [B]ranches" },
    { "<leader>gB", function() Snacks.git.blame_line() end,               desc = "[G]it: [B]lame Curr Line" },
    { "<leader>gD", function() Snacks.picker.git_diff() end,              desc = "[G]it: [D]iff (Overview)" },
    { "<leader>gl", function() Snacks.picker.git_log() end,               desc = "[G]it: Log" },
    { "<leader>gs", function() Snacks.picker.git_status() end,            desc = "[G]it: [S]tatus" },
    { "<leader>gS", function() Snacks.picker.git_stash() end,             desc = "[G]it: [S]tash" },
    { "<leader>go", function() Snacks.gitbrowse() end,                    desc = "[G]it: [O]pen in browser" },
    { "<leader>gg", function() Snacks.lazygit.open() end,                 desc = "[G]it: open Lazy[G]it" },

    { "]w",         function() Snacks.words.jump(1, true) end,            desc = "Next word occurrence" },
    { "[w",         function() Snacks.words.jump(-1, true) end,           desc = "Prev word occurrence" },
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
  ---@module "snacks"
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    explorer = {
      replace_netrw = true, -- Replace netrw with the snacks explorer
      trash = true,         -- Use the system trash when deleting files
    },
    gitbrowse = { enabled = true },
    indent = {
      enabled = true,
      animate = { enabled = false },
      chunk = {
        enabled = true,
        char = {
          corner_top    = "╭",
          corner_bottom = "╰",
          horizontal    = "─",
          vertical      = "│",
          arrow         = "⟩",
        },
        hl = ui_utils.color_cycle,
      },
      scope = {
        hl = ui_utils.color_cycle,
      },
    },
    input = {
      enabled = true,
      icon = prompt_icon,
    },
    lazygit = {
      enabled = true,
      config = {
        gui = {
          nerdFontsVersion = vim.g.use_icons and "3" or "",
        },
      },
    },
    picker = {
      enabled = true,
      prompt = prompt_icon,
      icons = {
        kinds = ui_utils.get_icon_set(),
      },
      layout = {
        layout = {
          width = 0.95,
          height = 0.95,
        },
      },
      sources = {
        files = {
          dirs = { fileopts.start_search_path() },
          exclude = fileopts.exclude_globs,
          hidden = true,
          ignore = false,
        },
        grep = {
          dirs = { fileopts.start_search_path() },
          hidden = true,
          ignore = false,
        },
        explorer = {
          cycle = true,
          auto_close = true,
          hidden = true,
          ignore = false,
          -- View when opening up explorer on a directory
          -- Use preset = "sidebar" in specific invocations (such as keymap)
          layout = { preset = "default" },
          include = {
            "dot-*",
            ".env",
          },
        },
        projects = {
          dev = { "~/Repositories/", "~/dotfiles" },
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
    terminal = {
      enabled = true,
    },
    toggle = {
      enabled = true,
    },
    words = {
      enabled = true,
    },
    zen = {
      enabled = true,
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
      terminal = {
        relative = "editor",
        width = 0.9,
        height = 0.9,
      },
      zen = {
        relative = "editor",
        width = 0.85,
        backdrop = {
          transparent = true,
          blend = 15,
        },
      },
    },
    dashboard = {
      enabled = true,
      preset = {
        keys = {
          { icon = "📄", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = "🔍", key = "/", desc = "Search", action = function() Snacks.picker.grep() end },
          { icon = "🧭", key = "b", desc = "Browse Files", action = explorer_fullscreen },
          { icon = "📁", key = "f", desc = "Find Files", action = function() Snacks.picker.files() end },
          { icon = "✨", key = "s", desc = "Smart Find", action = function() Snacks.picker.smart() end },
          { icon = "📦", key = "p", desc = "Projects", action = function() Snacks.picker.projects() end },
          { icon = "⏮️", key = "s", desc = "Last session", action = "<leader>sL" },
          { icon = "💾", key = "S", desc = "Select session", action = "<leader>sl" },
          { icon = "⚙️", key = "c", desc = "Edit Config", action = ":lua Snacks.explorer({cwd = vim.fn.stdpath('config')})" },
          { icon = "🚪", key = "q", desc = "Quit", action = ":qa" },
        },
        header = ui_utils.neovim_logo .. "\n" .. get_greeting() .. ", "
            .. (os.getenv("USER") or os.getenv("USERNAME") or "User") .. ".",
      },
      sections = {
        { section = "header" },
        { section = "keys", padding = 1 },
        { section = "recent_files", padding = 1, indent = 2, limit = 5, title = "Recent files", icon = "🕘" },
        { section = "projects", padding = 1, indent = 2, limit = 5, title = "Recent projects", icon = "🗃️" },
        { section = "startup" },
        {
          padding = { 0, 2 },
          text = { { get_footer(), hl = "Comment" } },
        },
      },
    },
  },
}
