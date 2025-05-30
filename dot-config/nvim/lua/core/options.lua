-- .config/nvim/lua/core/options.lua

-- ===================================================================
-- General Settings
-- ===================================================================
vim.opt.encoding = "utf-8"                       -- Default encoding
vim.opt.fileformats = "unix,dos"                 -- Line ending support
vim.opt.shortmess:append("I")                    -- Disable intro message
vim.opt.autoread = true                          -- Reload changed files
vim.opt.backspace = { "indent", "eol", "start" } -- Full backspace
vim.opt.clipboard:append("unnamedplus")          -- System clipboard integration
vim.opt.autoread       = true                    -- Auto-reload when files externally changed
vim.opt.mouse          = "a"                     -- Enable mouse in all modes
vim.opt.spelllang      = { "en_us" }
vim.opt.foldmethod     = "manual"                -- W/o LSP or Treesitter, manually create folds
vim.opt.foldlevel      = 99                      -- Minimum level to default being folded
vim.opt.foldlevelstart = 10                      -- Anything below this level will be folded on start
vim.opt.foldnestmax    = 4                       -- How many levels deep to nest
vim.opt.undofile       = true                    -- Keep persisitent undo history between sessions
vim.opt.undodir        = vim.fn.stdpath("data") .. "/undo"

-- ===================================================================
-- User Interface
-- ===================================================================
vim.opt.number         = true -- Line numbers
vim.opt.termguicolors  = true -- True color support
vim.opt.cursorline     = true -- Highlight current line
vim.opt.showmode       = true -- Show current mode (turn off in statusline plugins)
vim.opt.signcolumn     = "yes"
vim.opt.pumheight      = 15   -- Popup menu height limit
vim.opt.pumblend       = 10   -- Popup menu transparency
-- vim.opt.winborder      = "rounded" -- Border for windows

-- ===================================================================
-- Window and Buffer Management
-- ===================================================================
vim.opt.splitright     = true -- Default split rightwards
vim.opt.splitbelow     = true -- Default split downwards
vim.opt.scrolloff      = 10   -- Context lines when scrolling
vim.opt.winwidth       = 30   -- Minimum window width
vim.opt.winminwidth    = 10   -- Minimum inactive window width

-- ===================================================================
-- Text Display and Wrapping
-- ===================================================================
vim.opt.wrap           = true -- Enable line wrapping
vim.opt.linebreak      = true -- Wrap at word boundaries
vim.opt.showbreak      = "↳ " -- Wrapped line indicator
vim.opt.breakindent    = true -- Indent wrapped lines

-- ===================================================================
-- Indentation and Tabs
-- ===================================================================
vim.opt.tabstop        = 4    -- Visual tab width
vim.opt.shiftwidth     = 4    -- Autoindent width
vim.opt.softtabstop    = 4    -- Spaces per tab keypress
vim.opt.expandtab      = true -- Convert tabs to spaces
vim.opt.smartindent    = true -- Context-aware indents
vim.opt.shiftround     = true -- Round indents to multiples

-- ===================================================================
-- Character lists
-- ===================================================================
vim.opt.list           = true
vim.opt.listchars      = { tab = "▸ ", trail = "·", nbsp = "␣" }
vim.opt.fillchars      = { foldopen = "▾", foldsep = "│", foldclose = "▸" }

-- ===================================================================
-- Search and Matching
-- ===================================================================
vim.opt.ignorecase     = true      -- Case-insensitive search
vim.opt.smartcase      = true      -- Case-sensitive if uppercase
vim.opt.hlsearch       = true      -- Highlight matches
vim.opt.incsearch      = true      -- Incremental search (highlight while typing)
vim.opt.inccommand     = "nosplit" -- Live substitution preview

-- ===================================================================
-- Completion and Command Line
-- ===================================================================
vim.opt.wildmenu       = true                              -- Enhanced command completion
vim.opt.wildmode       = "list:longest,full"               -- Completion behavior
vim.opt.completeopt    = { "menu", "menuone", "noselect" } -- Completion options

-- ===================================================================
-- Performance Optimizations
-- ===================================================================
vim.opt.lazyredraw     = true -- Faster macro execution
vim.opt.synmaxcol      = 300  -- Limit syntax highlighting after some columns
