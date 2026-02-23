-- .config/nvim/lua/core/options.lua

-- ============================================================================
-- EDITING BEHAVIOR
-- ============================================================================
vim.opt.encoding    = "utf-8"
vim.opt.fileformats = "unix,dos"
vim.opt.backspace   = { "indent", "eol", "start" }
vim.opt.mouse       = "a"
vim.opt.virtualedit = "block" -- Allow cursor past EOL in visual block mode
vim.opt.autoread    = true    -- Auto-reload externally changed files
vim.opt.confirm     = true    -- Prompt to save instead of error on :q
vim.opt.undofile    = true    -- Persistent undo between sessions
vim.opt.undodir     = vim.fn.stdpath("data") .. "/undo"
vim.opt.spelllang   = { "en_us" }

-- Clipboard (deferred to avoid startup slowdown)
vim.opt.clipboard   = ""
vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"

  if vim.g.is_ssh then
    -- Use OSC52 for copy only, and use local registers to do paste reads
    -- Paste reads through OSC52 should be avoided as it exposes clipboard contents to any process
    -- Use system shortcuts for pasting over SSH (e.g. Ctrl+Shift+v)
    local function paste()
      return {
        vim.fn.split(vim.fn.getreg(""), "\n"),
        vim.fn.getregtype(""),
      }
    end

    vim.g.clipboard = {
      name = "OSC 52",
      copy = {
        ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
        ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
      },
      paste = {
        ["+"] = paste,
        ["*"] = paste,
      },
    }
  end
end)

-- ============================================================================
-- UI & VISUAL FEEDBACK
-- ============================================================================
vim.opt.number        = true
vim.opt.termguicolors = true
vim.opt.cursorline    = true
vim.opt.showmode      = true
vim.opt.signcolumn    = "yes"
vim.opt.colorcolumn   = "120"
vim.opt.scrolloff     = 10    -- Keep context when scrolling
vim.opt.shortmess:append("I") -- Disable intro message

vim.o.guifont       = "Geist_Mono,Consolas,Segoe_UI_Emoji,Symbols_Nerd_Font_Mono:h10"
vim.opt.guicursor   =
    "a:blinkon0," ..    -- disable cursor blinking in all modes
    "n-v-c:block," ..   -- normal/visual/command: solid block
    "i-ci-ve:ver25," .. -- insert modes: vertical bar (25% width)
    "r-cr:hor20," ..    -- replace modes: underline
    "o:hor50"           -- operator-pending: thicker underline

-- Wrapping
vim.opt.wrap        = true
vim.opt.linebreak   = true
vim.opt.showbreak   = "↳ "
vim.opt.breakindent = true

-- Whitespace characters
vim.opt.list        = true
vim.opt.listchars   = { tab = "▸ ", trail = "·", nbsp = "␣" }
vim.opt.fillchars   = { foldopen = "▾", foldsep = "│", foldclose = "▸" }

-- ============================================================================
-- WINDOWS & SPLITS
-- ============================================================================
vim.opt.splitright  = true
vim.opt.splitbelow  = true
vim.opt.winwidth    = 30
vim.opt.winminwidth = 10

-- ============================================================================
-- POPUPS & MENUS
-- ============================================================================
vim.opt.pumheight   = 15
vim.opt.pumblend    = 10
vim.opt.wildmenu    = true
vim.opt.wildmode    = "list:longest,full"
vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- ============================================================================
-- INDENTATION
-- ============================================================================
vim.opt.tabstop     = 4
vim.opt.shiftwidth  = 4
vim.opt.softtabstop = 4
vim.opt.expandtab   = true
vim.opt.smartindent = true
vim.opt.shiftround  = true
-- vim.opt.formatoptions:remove("cro") -- Disable auto-comment continuation

-- ============================================================================
-- SEARCH
-- ============================================================================
vim.opt.ignorecase  = true
vim.opt.smartcase   = true
vim.opt.hlsearch    = true
vim.opt.incsearch   = true
vim.opt.inccommand  = "nosplit"

if vim.fn.executable("rg") == 1 then
  vim.opt.grepprg = "rg --vimgrep --smart-case --hidden --follow " ..
      "--glob '!.git' --glob '!node_modules' " ..
      "--max-columns=150 --max-filesize=1M"
  vim.opt.grepformat = "%f:%l:%c:%m,%f:%l:%m,%f:%m"
end

-- ============================================================================
-- FOLDING
-- ============================================================================
vim.opt.foldmethod     = "manual"
vim.opt.foldlevel      = 99
vim.opt.foldlevelstart = 15
vim.opt.foldnestmax    = 4

-- ============================================================================
-- SESSIONS
-- ============================================================================
vim.opt.sessionoptions = {
  "buffers", -- Save all buffers (not just visible ones)
  "curdir",
  "tabpages",
  "winsize",
  "globals", -- Global variables
  "skiprtp", -- Don't save runtime path (prevents path conflicts)
  "folds",
}

-- ============================================================================
-- PERFORMANCE
-- ============================================================================
vim.opt.updatetime     = vim.g.is_ssh and 750 or 250 -- CursorHold/swap write interval (ms)
vim.opt.timeoutlen     = vim.g.is_ssh and 500 or 150 -- Key sequence timeout (ms)
vim.opt.synmaxcol      = 180                         -- How many columns to highlight
vim.opt.jumpoptions    = "view"                      -- Restore view when jumping

-- Use swap files over SSH connections that could disconnect
vim.opt.swapfile       = vim.g.is_ssh and true or false
