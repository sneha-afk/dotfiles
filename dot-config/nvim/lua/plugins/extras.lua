-- .config/nvim/lua/plugins/extras.lua
-- Nice-to-have/aesthetic plugins

return {
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
            separator = "  ",
            extends = "…",
          },
          menu = {
            -- separator = "  ",
            indicator = "  ",
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
  },

  {
    "m4xshen/hardtime.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>hd",
        function()
          vim.cmd("Hardtime disable")
          vim.notify("Hardtime disabled", vim.log.levels.INFO)
        end,
        desc = "[H]ardtime: [d]isable",
      },
      { "<leader>hT", "<cmd>Hardtime toggle<cr>", desc = "[H]ardtime: [T]oggle" },
    },
    opts = {
      disable_mouse = false,
      restricted_keys = {
        -- ["h"] = false,
        ["j"] = false,
        ["k"] = false,
        -- ["l"] = false,
      },
      -- let me live pls
      disabled_keys = {
        ["<Up>"] = false,
        ["<Down>"] = false,
        ["<Left>"] = false,
        ["<Right>"] = false,
      },
      disabled_filetypes = {
        ["dropbar_menu"] = true,
        ["dropbar_menu_fzf"] = true,
        ["dropbar_preview"] = true,
      },

      hints = {
        ["ggVG:"] = {
          message = function() return "Use :% instead of ggVG: to operate on the entire document" end,
          length = 5,
        },
        ["[dcyvV][ia][%(%)]"] = {
          message = function(keys) return "Use " .. keys:sub(1, 2) .. "b instead of " .. keys end,
          length = 3,
        },
        ["[dcyvV][ia][%{%}]"] = {
          message = function(keys) return "Use " .. keys:sub(1, 2) .. "B instead of " .. keys end,
          length = 3,
        },
      },
    },
  },
}
