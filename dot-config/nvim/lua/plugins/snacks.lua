-- .config/nvim/lua/plugins/snacks.lua

local prompt_icon = vim.g.use_icons and " " or "> "

local function get_greeting()
  local hour = tonumber(os.date("%H"))
  if hour < 5 then return vim.g.use_icons and "🌙 Sleep well" or "Sleep well" end
  if hour < 12 then return vim.g.use_icons and "🌅 Good morning" or "Good morning" end
  if hour < 18 then return vim.g.use_icons and "🌞 Good afternoon" or "Good afternoon" end
  if hour < 22 then return vim.g.use_icons and "🌆 Good evening" or "Good evening" end
  return vim.g.use_icons and "✨ Good night" or "Good night"
end

local function get_footer()
  local version = vim.version()
  local nvim_version = string.format("NVIM v%d.%d.%d", version.major, version.minor, version.patch)
  local cwd = vim.fn.fnamemodify(vim.uv.cwd() or "", ":~")

  return string.format("%s • %s\n%s", os.date("%A, %B %d %Y • %I:%M %p"), nvim_version, cwd)
end

---@type snacks.picker.layout.Config
local right_sidebar = { preset = "sidebar", layout = { position = "right", width = 0.25 } }

local explorer_sidebar = function()
  Snacks.explorer({
    layout = right_sidebar,
    cwd = Snacks.git.get_root() or vim.uv.cwd(),
    auto_close = false,
    git_status = vim.g.show_git_status_in_tree ~= false, -- defaults to true if unset
  })
end

local explorer_fullscreen = function()
  Snacks.explorer({
    cwd = Snacks.git.get_root() or vim.uv.cwd(),
    git_status = vim.g.show_git_status_in_tree ~= false,
  })
end

local related_test_files = function()
  local name = vim.fn.expand("%:t:r")
  local ext = vim.fn.expand("%:e")

  local patterns = {
    go = name .. "_test.go",
    rb = name .. "_spec.rb",
    java = name .. "Test.java",
    js = name .. ".test.js",
    ts = name .. ".test.ts",
    jsx = name .. ".test.jsx",
    tsx = name .. ".test.tsx",
  }

  Snacks.picker.files({
    title = "Tests: Find Test",
    search = patterns[ext] or (name .. "_test"),
    layout = { preset = "select" },
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
    { "<leader>r",  function() Snacks.picker.resume() end,                desc = "Picker: [R]esume" },

    { "<leader>hn", function() Snacks.notifier.show_history() end,        desc = "[H]istory: [N]otifications" },
    { "<leader>.",  function() Snacks.scratch() end,                      desc = "Toggle scratch buffer" },
    { "<leader>ss", function() Snacks.scratch.select() end,               desc = "[S]cratch: [S]elect" },

    -- Find/file: current work and context, heavily used
    { "<leader>fb", function() Snacks.picker.lines() end,                 desc = "[F]ind: within [B]uffer" },
    { "<leader>fB", function() Snacks.picker.buffers() end,               desc = "[F]ind: open [B]uffers" },
    { "<leader>fd", function() Snacks.picker.diagnostics_buffer() end,    desc = "[F]ind: [D]iagnostics (buffer)" },
    { "<leader>fD", function() Snacks.picker.diagnostics() end,           desc = "[F]ind: [D]iagnostics (workspace)" },
    { "<leader>fe", explorer_sidebar,                                     desc = "[F]ile: [E]xplorer" },
    { "<leader>fE", explorer_fullscreen,                                  desc = "[F]ile: [E]xplorer (fullscreen)" },
    { "<leader>ff", function() Snacks.picker.files() end,                 desc = "[F]ind: [F]iles" },
    { "<leader>fg", function() Snacks.picker.grep() end,                  desc = "[F]ind: live [G]rep" },
    { "<leader>fj", function() Snacks.picker.jumps() end,                 desc = "[F]ind: [J]umps" },
    { "<leader>fp", function() Snacks.picker.projects() end,              desc = "[F]ind: [P]rojects" },
    { "<leader>fr", function() Snacks.picker.recent() end,                desc = "[F]ind: [R]ecent files" },
    { "<leader>fR", function() Snacks.explorer.reveal() end,              desc = "[F]ile: [R]eveal" },
    { "<leader>fs", function() Snacks.picker.smart() end,                 desc = "[F]ind: [S]mart" },
    { "<leader>ft", related_test_files,                                   desc = "[F]ind: [T]est files" },

    -- Search operations: system-wide, less used
    { "<leader>sc", function() Snacks.picker.commands() end,              desc = "[S]earch: [C]ommands" },
    { "<leader>sC", function() Snacks.picker.command_history() end,       desc = "[S]earch: [C]ommand history" },
    { "<leader>sh", function() Snacks.picker.search_history() end,        desc = "[S]earch: [H]istory" },
    { "<leader>sH", function() Snacks.picker.help() end,                  desc = "[S]earch: [H]elp tags" },
    { "<leader>sk", function() Snacks.picker.keymaps() end,               desc = "[S]earch: [K]eymaps" },
    { "<leader>sm", function() Snacks.picker.marks() end,                 desc = "[S]earch: [M]arks" },
    { "<leader>sM", function() Snacks.picker.man() end,                   desc = "[S]earch: [M]an pages" },
    { "<leader>sP", function() Snacks.picker.pickers() end,               desc = "[S]earch: [P]ickers" },
    { "<leader>sq", function() Snacks.picker.qflist() end,                desc = "[S]earch: [Q]uickfix list" },
    { "<leader>st", function() Snacks.picker.treesitter() end,            desc = "[S]earch: [T]reesitter" },
    { "<leader>su", function() Snacks.picker.undo() end,                  desc = "[S]earch: [U]ndo history" },

    -- LSP operations
    { "gd",         function() Snacks.picker.lsp_definitions() end,       desc = "Goto Definition" },
    { "gD",         function() Snacks.picker.lsp_declarations() end,      desc = "Goto Declaration" },
    { "gR",         function() Snacks.picker.lsp_references() end,        desc = "Goto references",                  nowait = true },
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
    { "<leader>gf", function() Snacks.picker.git_log_file() end,          desc = "[G]it: log [F]ile" },
    { "<leader>gl", function() Snacks.picker.git_log() end,               desc = "[G]it: Log" },
    { "<leader>gL", function() Snacks.picker.git_log_line() end,          desc = "[G]it: log [L]ine" },
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

    vim.api.nvim_create_user_command("FindAll", function()
      Snacks.picker.files({
        hidden = true,
        ignore = true,
        exclude = {},
      })
    end, { desc = "Find files (+ hidden and ignored)" })

    vim.api.nvim_create_user_command("GrepAll", function(opts)
      Snacks.picker.grep({
        hidden = true,
        ignore = true,
        search = opts.args ~= "" and opts.args or nil,
      })
    end, { nargs = "?", desc = "Grep (+ hidden and ignored)" })
  end,
  ---@module "snacks"
  ---@type snacks.Config
  opts = {
    bigfile = {
      enabled = true,
      notify = true,
      size = 1 * 1024 * 1024, -- 1MB
      line_length = 1000,
      ---@param ctx {buf: number, ft:string}
      setup = function(ctx)
        if vim.fn.exists(":NoMatchParen") ~= 0 then
          vim.cmd([[NoMatchParen]])
        end
        Snacks.util.wo(0, { foldmethod = "manual", statuscolumn = "", conceallevel = 0 })
        vim.b.completion = false
        vim.b.minianimate_disable = true
        vim.b.minihipatterns_disable = true
        vim.opt_local.spell = false
        vim.opt_local.swapfile = false
        vim.opt_local.undofile = false
        vim.opt_local.breakindent = false
        vim.opt_local.statuscolumn = ""
        vim.opt_local.signcolumn = "no"
        vim.opt_local.foldcolumn = "0"
        vim.opt_local.winbar = ""
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(ctx.buf) then
            vim.bo[ctx.buf].syntax = ctx.ft
          end
        end)
      end,
    },
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
        hl = require("utils.ui").color_cycle,
      },
      scope = {
        hl = require("utils.ui").color_cycle,
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
        kinds = require("utils.ui").get_icon_set(),
      },
      layout = {
        layout = {
          width = 0.95,
          height = 0.95,
        },
      },
      sources = {
        files = {
          dirs = { require("utils.paths").start_search_path() },
          exclude = require("utils.globs").get_exclude_globs(),
          hidden = true,
          ignore = false,
        },
        grep = {
          dirs = { require("utils.paths").start_search_path() },
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
        commands = {
          layout = { preset = "select" },
        },
        diagnostics_buffer = {
          layout = right_sidebar,
          auto_close = false,
        },
        keymaps = {
          layout = { preset = "vscode" },
        },
        lsp_symbols = {
          layout = right_sidebar,
          auto_close = false,
        },
        pickers = {
          layout = { preset = "select" },
        },
        treesitter = {
          layout = right_sidebar,
          auto_close = false,
        },
      },
    },
    scope = { enabled = true },
    scratch = {
      enabled = true,
      icon = "⚏",
      ft = "markdown",
    },
    statuscolumn = {
      enabled = true,
      fold = { open = true },
    },
    toggle = { enabled = true },
    words = { enabled = not vim.g.is_ssh },
    zen = { enabled = true },
    notifier = {
      timeout = 3000, -- in ms
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
          { icon = "✨", key = "m", desc = "Smart Find", action = function() Snacks.picker.smart() end },
          { icon = "📦", key = "p", desc = "Projects", action = function() Snacks.picker.projects() end },
          { icon = "⏮️", key = "s", desc = "Last session", action = "<leader>sL" },
          { icon = "💾", key = "S", desc = "Select session", action = "<leader>sl" },
          { icon = "⚙️", key = "c", desc = "Edit Config", action = ":lua Snacks.explorer({cwd = vim.fn.stdpath('config')})" },
          { icon = "🚪", key = "q", desc = "Quit", action = ":qa" },
        },
        header = require("utils.ui").neovim_logo .. "\n" .. get_greeting() .. ", "
            .. (os.getenv("USER") or os.getenv("USERNAME") or "User") .. ".",
      },
      sections = {
        { section = "header" },
        { section = "keys", padding = 1 },
        { section = "recent_files", padding = 1, indent = 2, limit = 8, title = "Recent files", icon = "🕘" },
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
