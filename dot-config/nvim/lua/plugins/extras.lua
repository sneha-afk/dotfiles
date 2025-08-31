-- .config/nvim/lua/plugins/extras.lua
-- Nice-to-have/aesthetic plugins

return {
  {
    "echasnovski/mini.map",
    event = "UIEnter",
    version = false,
    keys = {
      { "<leader>mt", function() MiniMap.toggle() end,       desc = "Mini[M]ap: [T]oggle" },
      { "<leader>mf", function() MiniMap.toggle_focus() end, desc = "Mini[M]ap: [F]ocus" },
    },
    config = function()
      local minimap = require("mini.map")
      minimap.setup({
        integrations = {
          minimap.gen_integration.diagnostic({
            error = "DiagnosticFloatingError",
            warn  = "DiagnosticFloatingWarn",
            info  = "DiagnosticFloatingInfo",
            hint  = "DiagnosticFloatingHint",
          }),
          minimap.gen_integration.diff({
            add = "DiffAdd",
            change = "DiffChange",
            delete = "DiffDelete",
          }),
        },
        symbols = {
          encode = minimap.gen_encode_symbols.dot("3x2"),
        },
        window = {
          show_integration_count = false,
          width = 10,
        },
      })

      local excluded_filetypes = {
        ministarter = true,
        oil = true,
        qf = true,
        help = true,
        ["leetcode.nvim"] = true,
      }


      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          if excluded_filetypes[vim.bo.filetype] then
            return
          end
          MiniMap.open()
        end,
      })
    end,
  },

  -- Dropbar breadcrumb menu at top of screen
  {
    "Bekaboo/dropbar.nvim",
    lazy = false,
    dependencies = {
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    ---@module "dropbar"
    ---@type dropbar_configs_t
    opts = {
      menu = {
        win_configs = {
          border = "rounded",
        },
      },
      icons = {
        enable = true,
        ui = {
          bar = {
            separator = "  ",
            extends = "…",
          },
          menu = {
            -- separator = "  ",
            indicator = "  ",
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
            String = '"" ',
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
            WhileStatement = "while ",
          },
        },
      },
    },
    config = function(_, opts)
      require("dropbar").setup(opts)

      local dropbar_api = require("dropbar.api")
      vim.keymap.set("n", "<Leader>;", dropbar_api.pick,                { desc = "Pick symbols in winbar" })
      vim.keymap.set("n", "[;",        dropbar_api.goto_context_start,  { desc = "Go to start of current context" })
      vim.keymap.set("n", "];",        dropbar_api.select_next_context, { desc = "Select next context" })
    end,
  },

}
