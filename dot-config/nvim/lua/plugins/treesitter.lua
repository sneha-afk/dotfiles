-- .config/nvim/lua/plugins/treesitter.lua

-- Treesitter going through archival of master branch
local which_branch = "master"

return {
  "nvim-treesitter/nvim-treesitter",
  branch = which_branch,
  lazy = false,
  build = ":TSUpdate",
  dependencies = {
    {
      "nvim-treesitter/nvim-treesitter-textobjects",
      branch = which_branch,
    },
  },
  ---@module "nvim-treesitter.configs"
  ---@class TSConfig
  opts = {
    ensure_installed = {},
    sync_install = false,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
      disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- in KB
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
        return ok and stats and stats.size > max_filesize
      end,
    },
    indent = {
      enable = true,
      disable = { "python", "yaml" },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["af"] = { query = "@function.outer", desc = "Select outer part of a function" },
          ["if"] = { query = "@function.inner", desc = "Select inner part of a function" },
          ["ac"] = { query = "@class.outer", desc = "Select outer part of a class" },
          ["ic"] = { query = "@class.inner", desc = "Select inner part of a class" },
          ["aa"] = { query = "@parameter.outer", desc = "Select outer part of a parameter/argument" },
          ["ia"] = { query = "@parameter.inner", desc = "Select inner part of a parameter/argument" },
          ["ab"] = { query = "@block.outer", desc = "Select outer part of a block" },
          ["ib"] = { query = "@block.inner", desc = "Select inner part of a block" },
          ["al"] = { query = "@loop.outer", desc = "Select outer part of a loop" },
          ["il"] = { query = "@loop.inner", desc = "Select inner part of a loop" },
          ["ai"] = { query = "@conditional.outer", desc = "Select outer part of a conditional" },
          ["ii"] = { query = "@conditional.inner", desc = "Select inner part of a conditional" },
          ["as"] = { query = "@statement.outer", desc = "Select outer part of a statement" },
          ["is"] = { query = "@statement.inner", desc = "Select inner part of a statement" },
          ["am"] = { query = "@call.outer", desc = "Select outer part of a function call" },
          ["im"] = { query = "@call.inner", desc = "Select inner part of a function call" },
          ["ad"] = { query = "@comment.outer", desc = "Select outer part of a comment" },
          ["id"] = { query = "@comment.inner", desc = "Select inner part of a comment" },
        },
      },
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = {
          ["]f"] = { query = "@function.outer", desc = "Next function start" },
          ["]c"] = { query = "@class.outer", desc = "Next class start" },
        },
        goto_next_end = {
          ["]F"] = { query = "@function.outer", desc = "Next function end" },
          ["]C"] = { query = "@class.outer", desc = "Next class end" },
        },
        goto_previous_start = {
          ["[f"] = { query = "@function.outer", desc = "Previous function start" },
          ["[c"] = { query = "@class.outer", desc = "Previous class start" },
        },
        goto_previous_end = {
          ["[F"] = { query = "@function.outer", desc = "Previous function end" },
          ["[C"] = { query = "@class.outer", desc = "Previous class end" },
        },
      },
    },
  },
  config = function(_, opts)
    local treesitter = require("nvim-treesitter")
    if which_branch == "master" then
      require("nvim-treesitter.configs").setup(opts) -- Master branch has a configs module
    else
      treesitter.setup(opts)                         -- Main removes the config module
    end

    if which_branch == "main" then
      vim.api.nvim_create_autocmd("FileType", {
        desc = "Enable treesitter highlighting for installed groups",
        group = vim.api.nvim_create_augroup("Treesitter_Custom", { clear = false }),
        pattern = treesitter.get_installed(),
        callback = function()
          vim.treesitter.start()
        end,
      })
    end

    vim.api.nvim_create_autocmd("FileType", {
      desc = "If available, use treesitter as the folding method in the current buffer",
      group = vim.api.nvim_create_augroup("Treesitter_Custom", { clear = false }),
      callback = function(args)
        local buf = args.buf
        if vim.treesitter.highlighter.active[buf] then
          vim.opt_local.foldmethod = "expr"
          vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
        end
      end,
    })
  end,
}
