return {
  -- Display diff signs in gutter
  {
    "nvim-mini/mini.diff",
    enabled = false,
    version = false,
    event = "VeryLazy",
    keys = {
      {
        "<leader>gd",
        function() require("mini.diff").toggle_overlay(0) end,
        desc = "[G]it: toggle [D]iff Overlay",
      },
    },
    opts = {
      view = {
        style = "sign",
        signs = { add = "┃", change = "┇", delete = "━" },
      },
    },
    config = function(_, opts)
      require("mini.diff").setup(opts)

      local hl = vim.api.nvim_set_hl
      hl(0, "MiniDiffSignAdd",        { link = "DiffAdd" })
      hl(0, "MiniDiffSignChange",     { link = "DiffChange" })
      hl(0, "MiniDiffSignDelete",     { link = "DiffDelete" })

      hl(0, "MiniDiffOverAdd",        { link = "DiffAdd" })
      hl(0, "MiniDiffOverChange",     { link = "DiffChange" })
      hl(0, "MiniDiffOverChangeBuf",  { link = "Comment" })
      hl(0, "MiniDiffOverContext",    { link = "Comment" })
      hl(0, "MiniDiffOverContextBuf", { link = "Comment" })
      hl(0, "MiniDiffOverDelete",     { link = "DiffDelete" })
    end,
  },
  {
    "echasnovski/mini.map",
    enabled = false,
    event = "VeryLazy",
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
          width = 8,
        },
      })

      local excluded_filetypes = {
        ministarter = true,
        oil = true,
        qf = true,
        help = true,
        ["leetcode.nvim"] = true,
      }

      local function open_map()
        if excluded_filetypes[vim.bo.filetype] then
          return
        end
        minimap.open()
      end

      vim.schedule(open_map)
    end,
  },
  {
    "Bekaboo/dropbar.nvim",
    enabled = false,
    event = { "BufReadPost", "BufNewFile" },
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
            separator = "  ",
            extends = "…",
          },
          menu = {
            -- separator = "  ",
            indicator = " ",
          },
        },
        kinds = {
          symbols = require("utils.ui").get_icon_set(),
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
  } }
