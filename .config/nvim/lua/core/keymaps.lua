-- .config/nvim/lua/core/keymaps.lua
-- Globally available keymaps

-- Format for keymaps: { mode = "n", key="", action=, desc=}
-- Action can be a function reference, function reference, or string
local keymaps = {
  -- Terminal operations
  { "n", "<leader>ht", "<cmd>split | term<cr>i",  "Open horizontal terminal" },
  { "n", "<leader>vt", "<cmd>vsplit | term<cr>i", "Open vertical terminal" },
  { "t", "<Esc>",      "<C-\\><C-n>",             "Exit terminal mode" },
  { "t", "<C-w>h",     "<C-\\><C-n><C-w>h",       "Move left from terminal" },
  { "t", "<C-w>j",     "<C-\\><C-n><C-w>j",       "Move down from terminal" },
  { "t", "<C-w>k",     "<C-\\><C-n><C-w>k",       "Move up from terminal" },
  { "t", "<C-w>l",     "<C-\\><C-n><C-w>l",       "Move right from terminal" },
  { "t", "<C-w>q",     "<C-\\><C-n>:q<CR>",       "Close terminal" },
  { "t", "<C-u>",      "<C-\\><C-n><C-u>",        "Half page up" },
  { "t", "<C-d>",      "<C-\\><C-n><C-d>",        "Half page down" },

  -- File operations
  { "n", "<leader>w",  "<cmd>w<cr>",              "Save file" },
  { "n", "<leader>q",  "<cmd>q<cr>",              "Quit window" },
  { "n", "<leader>x",  "<cmd>wq<cr>",             "Save & quit" },
  { "n", "<leader>Q",  "<cmd>qa<cr>",             "Quit all windows" },

  -- Window management
  { "n", "<C-h>",      "<C-w>h",                  "Move to left window" },
  { "n", "<C-j>",      "<C-w>j",                  "Move to below window" },
  { "n", "<C-k>",      "<C-w>k",                  "Move to above window" },
  { "n", "<C-l>",      "<C-w>l",                  "Move to right window" },
  { "n", "<leader>vs", "<cmd>vsplit<cr>",         "[V]ertical [S]plit" },
  { "n", "<leader>hs", "<cmd>split<cr>",          "[H]orizontal [S]plit" },

  -- Buffer operations:
  { "n", "<leader>]",  "<cmd>bnext<cr>",          "[B]uffer [N]ext" },
  { "n", "<leader>[",  "<cmd>bprev<cr>",          "[B]uffer [P]revious" },
  { "n", "<leader>bd", "<cmd>bdelete<cr>",        "[B]uffer [D]elete" },
  { "n", "<leader>bD", "<cmd>bd!<cr>",            "[B]uffer [D]elete (force)" },

  -- Tab operations
  { "n", "<leader>tn", ":tabnew<CR>",             "Open new tab" },
  { "n", "<leader>tc", ":tabclose<CR>",           "Close current tab" },
  { "n", "<leader>to", ":tabonly<CR>",            "Close all other tabs" },
  { "n", "<leader>t]", ":tabnext<CR>",            "Go to next tab" },
  { "n", "<leader>t[", ":tabprevious<CR>",        "Go to previous tab" },
  { "n", "<leader>tm", ":tabmove<CR>",            "Move current tab to last" },
  { "n", "<leader>t1", "1gt",                     "Go to tab 1" },
  { "n", "<leader>t2", "2gt",                     "Go to tab 2" },
  { "n", "<leader>t3", "3gt",                     "Go to tab 3" },
  { "n", "<leader>t4", "4gt",                     "Go to tab 4" },
  { "n", "<leader>tp", ":tablast<CR>",            "Jump to last open tab" },

  -- Utilities
  { "n", "<leader>un", "<cmd>set nu!<cr>",        "[U]I Toggle line [N]umbers" },
  { "n", "<leader>ur", "<cmd>set rnu!<cr>",       "[U]I Toggle [R]elative line numbers" },
  { "n", "<leader>uw", "<cmd>set wrap!<cr>",      "[U]I Toggle line [W]rap" },
}

for _, km in ipairs(keymaps) do
  vim.keymap.set(km[1], km[2], km[3], {
    desc = km[4],
    noremap = true,
    silent = true,
  })
end
