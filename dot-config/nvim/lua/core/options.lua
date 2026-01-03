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
  vim.opt.grepprg = "rg --vimgrep"
end

-- ============================================================================
-- FOLDING
-- ============================================================================
vim.opt.foldmethod     = "manual"
vim.opt.foldlevel      = 99
vim.opt.foldlevelstart = 10
vim.opt.foldnestmax    = 4

-- ============================================================================
-- SESSIONS
-- ============================================================================
vim.opt.sessionoptions = {
  "buffers",  -- Save all buffers (not just visible ones)
  "curdir",   -- Save current directory
  "tabpages", -- Save tab layout
  "winsize",  -- Save window sizes
  "help",     -- Save help windows
  "globals",  -- Save global variables (needed by many plugins)
  "skiprtp",  -- Don't save runtime path (prevents path conflicts)
  "folds",    -- Save fold state
}

-- ============================================================================
-- PERFORMANCE
-- ============================================================================
vim.opt.updatetime     = 250    -- Faster CursorHold (LSP, diagnostics)
vim.opt.timeoutlen     = 300    -- Faster keymap timeout
vim.opt.synmaxcol      = 300    -- Limit syntax highlighting column
vim.opt.jumpoptions    = "view" -- Restore view when jumping
