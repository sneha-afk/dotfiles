-- .config/nvim/lua/core/keymaps.lua
-- Globally available keymaps

-- Format for keymaps: { mode = "n", key="", action=, desc=}
-- Action can be a function reference, function reference, or string
local M = {}

M.keymaps = {
  -- Terminal operations
  { mode = "n", key = "<leader>ht", action = "<cmd>split | term<cr>i",  desc = "Open horizontal terminal" },
  { mode = "n", key = "<leader>vt", action = "<cmd>vsplit | term<cr>i", desc = "Open vertical terminal" },
  { mode = "t", key = "<Esc>",      action = "<C-\\><C-n>",             desc = "Exit terminal mode" },
  { mode = "t", key = "<C-w>h",     action = "<C-\\><C-n><C-w>h",       desc = "Move left from terminal" },
  { mode = "t", key = "<C-w>j",     action = "<C-\\><C-n><C-w>j",       desc = "Move down from terminal" },
  { mode = "t", key = "<C-w>k",     action = "<C-\\><C-n><C-w>k",       desc = "Move up from terminal" },
  { mode = "t", key = "<C-w>l",     action = "<C-\\><C-n><C-w>l",       desc = "Move right from terminal" },
  { mode = "t", key = "<C-w>q",     action = "<C-\\><C-n>:q<CR>",       desc = "Close terminal" },
  { mode = "t", key = "<C-u>",      action = "<C-\\><C-n><C-u>",        desc = "Half page up" },
  { mode = "t", key = "<C-d>",      action = "<C-\\><C-n><C-d>",        desc = "Half page down" },

  -- File operations
  { mode = "n", key = "<leader>w",  action = "<cmd>w<cr>",              desc = "Save file" },
  { mode = "n", key = "<leader>q",  action = "<cmd>q<cr>",              desc = "Quit window" },
  { mode = "n", key = "<leader>x",  action = "<cmd>wq<cr>",             desc = "Save & quit" },
  { mode = "n", key = "<leader>Q",  action = "<cmd>qa<cr>",             desc = "Quit all windows" },

  -- Window management
  { mode = "n", key = "<C-h>",      action = "<C-w>h",                  desc = "Move to left window" },
  { mode = "n", key = "<C-j>",      action = "<C-w>j",                  desc = "Move to below window" },
  { mode = "n", key = "<C-k>",      action = "<C-w>k",                  desc = "Move to above window" },
  { mode = "n", key = "<C-l>",      action = "<C-w>l",                  desc = "Move to right window" },
  { mode = "n", key = "<leader>wv", action = "<cmd>vsplit<cr>",         desc = "[W]indow [V]ertical split" },
  { mode = "n", key = "<leader>wh", action = "<cmd>split<cr>",          desc = "[W]indow [H]orizontal split" },
  { mode = "n", key = "<leader>wd", action = "<cmd>split<cr>",          desc = "[W]indow [D]elete" },

  -- Buffer operations:
  { mode = "n", key = "<leader>bn", action = "<cmd>bnext<cr>",          desc = "[B]uffer [N]ext" },
  { mode = "n", key = "<leader>bp", action = "<cmd>bprev<cr>",          desc = "[B]uffer [P]revious" },
  { mode = "n", key = "<leader>bd", action = "<cmd>bdelete<cr>",        desc = "[B]uffer [D]elete" },

  -- Tab operations
  { mode = "n", key = "<leader>tn", action = ":tabnew<CR>",             desc = "Open new tab" },
  { mode = "n", key = "<leader>tc", action = ":tabclose<CR>",           desc = "Close current tab" },
  { mode = "n", key = "<leader>to", action = ":tabonly<CR>",            desc = "Close all other tabs" },
  { mode = "n", key = "<leader>tl", action = ":tabnext<CR>",            desc = "Go to next tab" },
  { mode = "n", key = "<leader>th", action = ":tabprevious<CR>",        desc = "Go to previous tab" },
  { mode = "n", key = "<leader>tm", action = ":tabmove<CR>",            desc = "Move current tab to last" },
  { mode = "n", key = "<leader>t1", action = "1gt",                     desc = "Go to tab 1" },
  { mode = "n", key = "<leader>t2", action = "2gt",                     desc = "Go to tab 2" },
  { mode = "n", key = "<leader>t3", action = "3gt",                     desc = "Go to tab 3" },
  { mode = "n", key = "<leader>t4", action = "4gt",                     desc = "Go to tab 4" },
  { mode = "n", key = "<leader>tp", action = ":tablast<CR>",            desc = "Jump to last open tab" },

  -- Utilities
  {
    mode = "n",
    key = "<leader>ur",
    desc = "[U]I Toggle [R]elative line numbers",
    action = function()
      vim.opt.relativenumber = not vim.opt.relativenumber._value
    end,

  },
}

function M.setup()
  for _, map in ipairs(M.keymaps) do
    vim.keymap.set(map.mode, map.key, map.action, { noremap = true, silent = true, desc = map.desc })
  end
end

return M
