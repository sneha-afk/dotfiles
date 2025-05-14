-- .config/nvim/lua/plugins/ui.lua

return {
  -- Display diff signs in gutter
  {
    "echasnovski/mini.diff",
    version = false,
    event = "UIEnter",
    keys = {
      { "<leader>gd", function() require("mini.diff").toggle_overlay(0) end, desc = "[G]it: toggle [D]iff Overlay" },
    },
    opts = {
      view = {
        style = "sign",
        signs = { add = "┃", change = "┇", delete = "━" },
      },
    },
    config = function(_, opts)
      require("mini.diff").setup(opts)

      vim.api.nvim_set_hl(0, "MiniDiffSignAdd", { link = "DiffAdd" })
      vim.api.nvim_set_hl(0, "MiniDiffSignChange", { link = "DiffChange" })
      vim.api.nvim_set_hl(0, "MiniDiffSignDelete", { link = "DiffDelete" })

      vim.api.nvim_set_hl(0, "MiniDiffOverAdd", { link = "DiffAdd" })
      vim.api.nvim_set_hl(0, "MiniDiffOverChange", { link = "DiffChange" })
      vim.api.nvim_set_hl(0, "MiniDiffOverChangeBuf", { link = "Comment" })
      vim.api.nvim_set_hl(0, "MiniDiffOverContext", { link = "Comment" })
      vim.api.nvim_set_hl(0, "MiniDiffOverContextBuf", { link = "Comment" })
      vim.api.nvim_set_hl(0, "MiniDiffOverDelete", { link = "DiffDelete" })
    end
  },
  -- Snacks!
  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 1000,
    dependencies = { "echasnovski/mini.diff", },
    ---@module "snacks"
    ---@type snacks.Config
    opts = {
      indent = {
        enabled = true,
        animate = { enabled = false },
      },
      input = {
        enabled = true,
        icon = "> ",
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
      styles = {
        input = {
          relative = "cursor",
          position = "float",
        },
        zen = {
          relative = "editor",
          width = 0.6,
          backdrop = { transparent = true, blend = 20 },
        },
      },
      notifier = {
        timeout = 3000,   -- in ms
        top_down = false, -- false for bottom up
        icons = {
          error = "[E] ",
          warn  = "[W] ",
          info  = "[I] ",
          debug = "[D] ",
          trace = "[T] ",
        },
      },
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          Snacks.toggle.indent():map("<leader>ui")
          Snacks.toggle.zen():map("<leader>z")
        end,
      })
    end,
  },
  {
    "Bekaboo/dropbar.nvim",
    event = "UIEnter",
    dependencies = {
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    opts = {
      icons = {
        enable = true,
        ui = {
          bar = {
            separator = " ) ",
            extends = "…",
          },
          menu = {
            -- separator = " ⟩ ",
            indicator = " ⟩ ",
          },
        },
        kinds = {
          symbols = {
            Array = "[] ",
            BlockMappingPair = "{} ",
            Boolean = "bool ",
            BreakStatement = "break ",
            Call = "fn() ",
            CaseStatement = "case ",
            Class = "class ",
            Color = "# ",
            Constant = "const ",
            Constructor = "ctor ",
            ContinueStatement = "cont ",
            Copilot = "AI ",
            Declaration = "decl ",
            Delete = "del ",
            DoStatement = "do ",
            Element = "elem ",
            Enum = "enum ",
            EnumMember = "enumval ",
            Event = "⍺ ",
            Field = "■ ",
            File = "⛶ ",
            Folder = "🖿",
            ForStatement = "for ",
            Function = "ƒ ",
            GotoStatement = "goto ",
            Identifier = "id ",
            IfStatement = "if ",
            Interface = "iface ",
            Keyword = "kw ",
            List = "☰ ",
            Log = "log ",
            Lsp = "LSP ",
            Macro = "macro ",
            MarkdownH1 = "# ",
            MarkdownH2 = "## ",
            MarkdownH3 = "### ",
            MarkdownH4 = "#### ",
            MarkdownH5 = "##### ",
            MarkdownH6 = "###### ",
            Method = "ƒ ",
            Module = "mod ",
            Namespace = "ns ",
            Null = "null ",
            Number = "123 ",
            Object = "▢ ",
            Operator = "op ",
            Package = "pkg ",
            Pair = "pair ",
            Property = "prop ",
            Reference = "ref ",
            Regex = "re ",
            Repeat = "loop ",
            Return = "ret ",
            RuleSet = "rules ",
            Scope = "{} ",
            Section = "§ ",
            Snippet = "✁ ",
            Specifier = "spec ",
            Statement = "stmt ",
            String = "\"\" ",
            Struct = "struct ",
            SwitchStatement = "switch ",
            Table = "tbl ",
            Terminal = "term ",
            Text = "txt ",
            Type = "type ",
            TypeParameter = "T ",
            Unit = "unit ",
            Value = "val ",
            Variable = "var ",
            WhileStatement = "while "
          },
        },
      },
    },
    config = function(_, opts)
      require("dropbar").setup(opts)

      local dropbar_api = require('dropbar.api')
      vim.keymap.set('n', '<Leader>;', dropbar_api.pick, { desc = 'Pick symbols in winbar' })
      vim.keymap.set('n', '[;', dropbar_api.goto_context_start, { desc = 'Go to start of current context' })
      vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })
    end
  },
}
