-- .config/nvim/lua/core/options.lua

-- ===================================================================
-- Core Editor Behavior
-- ===================================================================
vim.opt.encoding = "utf-8"                       -- Default encoding
vim.opt.fileformats = "unix,dos"                 -- Line ending support
vim.opt.shortmess:append("I")                    -- Disable intro message
vim.opt.autoread = true                          -- Reload changed files
vim.opt.backspace = { "indent", "eol", "start" } -- Full backspace
vim.opt.clipboard:append("unnamedplus")          -- System clipboard integration
vim.opt.autoread       = true                    -- Auto-reload when files externally changed
vim.opt.mouse          = "a"                     -- Enable mouse in all modes
vim.o.spelllang        = "en_us"

-- ===================================================================
-- User Interface
-- ===================================================================
vim.opt.number         = true  -- Line numbers
vim.opt.termguicolors  = true  -- True color support
vim.opt.cursorline     = true  -- Highlight current line
vim.opt.showmode       = false -- Disable mode text (handled by lualine)
vim.opt.pumheight      = 15    -- Popup menu height limit
vim.opt.pumblend       = 10    -- Popup menu transparency

-- ===================================================================
-- Window and Buffer Management
-- ===================================================================
vim.opt.splitright     = true -- Default split rightwards
vim.opt.splitbelow     = true -- Default split downwards
vim.opt.scrolloff      = 5    -- Context lines when scrolling
vim.opt.winwidth       = 30   -- Minimum window width
vim.opt.winminwidth    = 10   -- Minimum inactive window width

-- ===================================================================
-- Text Display and Wrapping
-- ===================================================================
vim.opt.wrap           = true -- Enable line wrapping
vim.opt.linebreak      = true -- Wrap at word boundaries
vim.opt.showbreak      = "↳ " -- Wrapped line indicator
vim.opt.breakindent    = true -- Indent wrapped lines
vim.opt.breakindentopt = "shift:4" -- Wrapped line indent size

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
vim.opt.listchars      = { tab = "▸ ", trail = "·", nbsp = "␣", }

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
