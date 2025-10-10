-- .config/nvim/lua/plugins/treesitter.lua
-- Prerequisites:
--   * `git` command line tool
--   * `gcc` or `clang` compiler toolchain
--   * `tree-sitter` CLI (required on `main` branch)
--   * `nodejs` (for some languages)

-- "ensure_installed" languages
local langs = {
  "lua",
  "markdown",
  "c",
  "python",
  "go",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    enabled = function()
      if vim.fn.executable("tree-sitter") == 1 then return true end
      vim.notify("nvim-treesitter: 'tree-sitter' CLI not found; disabling plugin", vim.log.levels.WARN)
      return false
    end,
    branch = "main",
    build = ":TSUpdate",
    ---@module "nvim-treesitter.config"
    ---@type TSConfig
    opts = {
      install_dir = vim.fn.stdpath("data") .. "/site",
    },
    config = function(_, opts)
      local treesitter = require("nvim-treesitter")
      treesitter.setup(opts)
      treesitter.install(langs)

      vim.api.nvim_create_autocmd("FileType", {
        pattern = treesitter.get_installed(),
        group = vim.api.nvim_create_augroup("Treesitter_Custom", { clear = true }),
        callback = function(args)
          local buf = args.buf
          local filetype = args.match

          -- Avoid running on unsupported languages
          local language = vim.treesitter.language.get_lang(filetype) or filetype
          if not vim.treesitter.language.add(language) then
            return
          end

          vim.treesitter.start(buf)
          vim.wo.foldmethod = "expr"
          vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
    },
    config = function(_, opts)
      local textobjects = require("nvim-treesitter-textobjects")
      textobjects.setup(opts)

      local map    = vim.keymap.set
      local select = require("nvim-treesitter-textobjects.select")
      local move   = require("nvim-treesitter-textobjects.move")

      local function map_select(lhs, query, desc)
        map({ "x", "o" }, lhs, function()
          select.select_textobject(query)
        end, { desc = desc })
      end

      local function map_move(lhs, fn, query, desc)
        map({ "n", "x", "o" }, lhs, function()
          fn(query)
        end, { desc = desc })
      end

      -------------------------------------------------------------------------
      -- SELECTIONS
      ------------------------------------------------------------------------
      local selections = {
        ["af"] = { "@function.outer", "Select outer function" },
        ["if"] = { "@function.inner", "Select inner function" },
        ["ac"] = { "@class.outer", "Select outer class" },
        ["ic"] = { "@class.inner", "Select inner class" },
        ["aa"] = { "@parameter.outer", "Select outer parameter" },
        ["ia"] = { "@parameter.inner", "Select inner parameter" },
        ["ab"] = { "@block.outer", "Select outer block" },
        ["ib"] = { "@block.inner", "Select inner block" },
        ["al"] = { "@loop.outer", "Select outer loop" },
        ["il"] = { "@loop.inner", "Select inner loop" },
        ["ai"] = { "@conditional.outer", "Select outer conditional" },
        ["ii"] = { "@conditional.inner", "Select inner conditional" },
        ["as"] = { "@statement.outer", "Select outer statement" },
        ["is"] = { "@statement.inner", "Select inner statement" },
        ["am"] = { "@call.outer", "Select outer call" },
        ["im"] = { "@call.inner", "Select inner call" },
        ["ad"] = { "@comment.outer", "Select outer comment" },
        ["id"] = { "@comment.inner", "Select inner comment" },
      }
      for lhs, spec in pairs(selections) do
        map_select(lhs, spec[1], spec[2])
      end

      -------------------------------------------------------------------------
      -- Movements
      -------------------------------------------------------------------------
      local movements = {
        -- Next start
        ["]m"] = { move.goto_next_start, "@function.outer", "Next function start" },
        ["]]"] = { move.goto_next_start, "@class.outer", "Next class start" },
        ["]o"] = { move.goto_next_start, { "@loop.inner", "@loop.outer" }, "Next loop start" },
        ["]s"] = { move.goto_next_start, "@local.scope", "Next local scope start" },
        ["]z"] = { move.goto_next_start, "@fold", "Next fold start" },
        ["]d"] = { move.goto_next, "@conditional.outer", "Next conditional" },

        -- Next end
        ["]M"] = { move.goto_next_end, "@function.outer", "Next function end" },
        ["]["] = { move.goto_next_end, "@class.outer", "Next class end" },

        -- Previous start
        ["[m"] = { move.goto_previous_start, "@function.outer", "Prev function start" },
        ["[["] = { move.goto_previous_start, "@class.outer", "Prev class start" },
        ["[d"] = { move.goto_previous, "@conditional.outer", "Prev conditional" },

        -- Previous end
        ["[M"] = { move.goto_previous_end, "@function.outer", "Prev function end" },
        ["[]"] = { move.goto_previous_end, "@class.outer", "Prev class end" },
      }
      for lhs, spec in pairs(movements) do
        map_move(lhs, spec[1], spec[2], spec[3])
      end
    end,
  },
}
