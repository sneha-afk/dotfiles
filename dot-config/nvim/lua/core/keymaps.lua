-- .config/nvim/lua/core/keymaps.lua
-- Globally available keymaps

local diagnostic = vim.diagnostic

-- Format for keymaps: { mode = "n", key=, desc=, action=}
-- Action can be a Lua function, function reference, or string
local keymaps = {
  -- Terminal operations
  { "n", "<leader>ht", "[H]orizontal [T]erminal",           "<cmd>split | term<cr>i" },
  { "n", "<leader>vt", "[V]ertical [T]erminal",             "<cmd>vsplit | term<cr>i" },
  { "t", "<Esc>",      "Exit terminal mode",                "<C-\\><C-n>" },
  { "t", "<C-w>h",     "Move left from terminal",           "<C-\\><C-n><C-w>h" },
  { "t", "<C-w>j",     "Move down from terminal",           "<C-\\><C-n><C-w>j" },
  { "t", "<C-w>k",     "Move up from terminal",             "<C-\\><C-n><C-w>k" },
  { "t", "<C-w>l",     "Move right from terminal",          "<C-\\><C-n><C-w>l" },
  { "t", "<C-w>q",     "Close terminal",                    "<C-\\><C-n>:q<CR>" },
  { "t", "<C-j>",      "Half page down",                    "<C-\\><C-n><C-d>" },
  { "t", "<C-k>",      "Half page up",                      "<C-\\><C-n><C-u>" },

  -- File operations
  { "n", "<leader>w",  "Save file",                         "<cmd>w<cr>" },
  { "n", "<leader>q",  "Quit window",                       "<cmd>q<cr>" },
  { "n", "<leader>x",  "Save & quit",                       "<cmd>wq<cr>" },
  { "n", "<leader>Q",  "Quit all windows",                  "<cmd>qa<cr>" },

  -- Window management
  { "n", "<C-h>",      "Move to left window",               "<C-w>h" },
  { "n", "<C-j>",      "Move to below window",              "<C-w>j" },
  { "n", "<C-k>",      "Move to above window",              "<C-w>k" },
  { "n", "<C-l>",      "Move to right window",              "<C-w>l" },
  { "n", "<leader>vs", "[V]ertical [S]plit",                "<cmd>vsplit<cr>" },
  { "n", "<leader>hs", "[H]orizontal [S]plit",              "<cmd>split<cr>" },

  -- Buffer operations
  { "n", "<leader>]b", "Go to next buffer",                 "<cmd>bnext<cr>" },
  { "n", "<leader>[b", "Go to previous buffer",             "<cmd>bprev<cr>" },
  { "n", "<leader>bd", "[B]uffer [D]elete",                 "<cmd>bdelete<cr>" },
  { "n", "<leader>bD", "[B]uffer [D]elete (force)",         "<cmd>bd!<cr>" },

  -- Tab operations
  { "n", "<leader>tn", "[T]ab: [N]ew",                      "<cmd>tabnew<CR>" },
  { "n", "<leader>tc", "[T]ab: [C]lose current",            "<cmd>tabclose<CR>" },
  { "n", "<leader>to", "[T]ab: close all [O]thers",         "<cmd>tabonly<CR>" },
  { "n", "<leader>]t", "Go to next tab",                    "<cmd>tabnext<CR>" },
  { "n", "<leader>[t", "Go to previous tab",                "<cmd>tabprevious<CR>" },
  { "n", "<leader>tm", "[T]ab: [M]ove current to last",     "<cmd>tabmove<CR>" },
  { "n", "<leader>tl", "[T]ab: jump to [L]ast open",        "<cmd>tablast<CR>" },
  { "n", "<leader>t1", "[T]ab: go to [1]",                  "1gt" },
  { "n", "<leader>t2", "[T]ab: go to [2]",                  "2gt" },
  { "n", "<leader>t3", "[T]ab: go to [3]",                  "3gt" },
  { "n", "<leader>t4", "[T]ab: go to [4]",                  "4gt" },

  -- Utilities
  { "n", "<leader>un", "[U]I: toggle line [N]umbers",       "<cmd>set nu!<cr>" },
  { "n", "<leader>ur", "[U]I: toggle [R]elative line nums", "<cmd>set rnu!<cr>" },
  { "n", "<leader>uw", "[U]I: toggle line [W]rap",          "<cmd>set wrap!<cr>" },
  { "n", "<leader>cs", "[C]lear [S]earch highlights",       "<cmd>nohl<cr>" },

  -- Diagnostics
  { "n", "<leader>dl", "[D]iagnostics: open [L]ist",        diagnostic.open_float },
  { "n", "<leader>df", "[D]iagnostics: [F]ile-local list",  diagnostic.setloclist },
  { "n", "<leader>da", "[D]iagnostics: [A]ll project-wide", function() diagnostic.setqflist({ open = true }) end },
  { "n", "[d",         "Previous diagnostic",               function() diagnostic.jump { count = -1, float = true } end },
  { "n", "]d",         "Next diagnostic",                   function() diagnostic.jump { count = 1, float = true } end },
  { "n", "<leader>dv", "[D]iagnostics: toggle [V]irtual text",
    function() diagnostic.config({ virtual_text = not diagnostic.config().virtual_text }) end
  },
  { "n", "<leader>dt", "[D]iagnostics: [T]oggle", function() diagnostic.enable(not diagnostic.is_enabled()) end },
}

local function map(mode, short, action, desc)
  vim.keymap.set(mode, short, action, {
    desc = desc,
    noremap = true,
    silent = true,
  })
end

for _, km in ipairs(keymaps) do map(km[1], km[2], km[4], km[3]) end
