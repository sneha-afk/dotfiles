-- .config/nvim/lua/plugins/leetcode.lua

--[[
-- Login instructions:
--  1. Go to Leetcode
--  2. Inspect -> Network
--  3. Search up graphql
--  4. Find "Cookie" under Request Headers
--  5. Copy the ENTIRE cookie to sign-in
--]]

return {
  "kawre/leetcode.nvim",
  cmd = "Leet",
  lazy = "leetcode.nvim" ~= vim.fn.argv()[1],
  build = ":TSUpdate html",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
  },
  ---@module "leetcode.config"
  ---@type lc.UserConfig
  opts = {
    ---@type lc.lang
    lang = "python3",

    ---@type lc.picker
    picker = { provider = "telescope" },
  },
  config = function(_, opts)
    require("leetcode").setup(opts)

    -- Needed to prevent localleader maps and other settings from leaking outside
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
      pattern = "*",
      callback = function(args)
        -- Need to allow manual folding so :Leet fold works
        vim.opt_local.foldmethod = "manual"

        local buf = args.buf
        local keymaps = {
          { "<localleader>c", "<cmd>Leet cookie update<cr>", desc = "Update login cookie", mode = "n" },
          { "<localleader>d", "<cmd>Leet desc<cr>",          desc = "Toggle description",  mode = "n" },
          { "<localleader>f", "<cmd>Leet fold<cr>",          desc = "Fold imports",        mode = "n" },
          { "<localleader>h", "<cmd>Leet hints<cr>",         desc = "See hints",           mode = "n" },
          { "<localleader>i", "<cmd>Leet info<cr>",          desc = "Information",         mode = "n" },
          { "<localleader>l", "<cmd>Leet list<cr>",          desc = "List of problems",    mode = "n" },
          { "<localleader>o", "<cmd>Leet open<cr>",          desc = "Open in browser",     mode = "n" },
          { "<localleader>r", "<cmd>Leet run<cr>",           desc = "Run tests",           mode = "n" },
          { "<localleader>R", "<cmd>Leet reset<cr>",         desc = "Reset (!)",           mode = "n" },
          { "<localleader>s", "<cmd>Leet submit<cr>",        desc = "Submit",              mode = "n" },
          { "<localleader>y", "<cmd>Leet yank<cr>",          desc = "Yank code section",   mode = "n" },
        }

        for _, keymap in ipairs(keymaps) do
          vim.keymap.set(keymap.mode, keymap[1], keymap[2], {
            buffer = buf,
            desc = keymap.desc,
            silent = true,
            noremap = true,
          })
        end
      end,
    })
  end,
}
