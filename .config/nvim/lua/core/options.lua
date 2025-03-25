-- ===================================================================
-- Basic Configuration
-- ===================================================================
vim.opt.encoding = 'utf-8'               -- Set encoding to UTF-8
vim.opt.fileencoding = 'utf-8'           -- File encoding
vim.opt.ff = 'unix'                      -- Use Unix file format (LF endings)
vim.opt.shortmess:append('I')            -- Skip intro message
vim.opt.scrolloff = 5                    -- Keep 5 lines of context above/below cursor
vim.opt.splitright = true                -- Vertical splits open to the right
vim.opt.wrap = true                      -- Wrap long lines
vim.opt.linebreak = true                 -- Don't break words when wrapping
vim.opt.wildmenu = true                  -- Enhanced command-line completion
vim.opt.wildmode = 'list:longest,full'   -- Show autocomplete matches
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' } -- Better completion behavior
vim.opt.backspace = { 'indent', 'eol', 'start' } -- Full backspace functionality

-- UI Settings
vim.opt.number = true                    -- Show line numbers
vim.opt.termguicolors = true             -- Enable true color support
vim.opt.cursorline = true                -- Highlight current line
vim.opt.signcolumn = 'yes'               -- Always show sign column
vim.opt.showmode = false                 -- Disable mode text (handled by lualine)

-- ===================================================================
-- Indentation and Tabs
-- ===================================================================
-- Note: 'filetype indent plugin on' is enabled by default in Neovim
--       'smarttab' and 'autoindent' are also default-enabled

vim.opt.tabstop = 4             -- Visual width of tab character
vim.opt.shiftwidth = 4          -- Size of autoindent
vim.opt.softtabstop = 4         -- Spaces inserted when pressing TAB
vim.opt.expandtab = true        -- Convert tabs to spaces
vim.opt.smartindent = true      -- Context-aware indentation for C-like code
vim.opt.shiftround = true       -- Round indent to shiftwidth multiples

-- =======================================
-- Line Wrapping
-- =======================================
vim.opt.breakindent = true       -- Indent wrapped lines
vim.opt.breakindentopt = 'shift:4'  -- Indent by 4 spaces

-- =======================================
-- Whitespace Visualization
-- =======================================
vim.opt.list = true              -- Show invisible chars
vim.opt.listchars = {
  tab = '▸ ',                    -- Tab characters
  trail = '·'                    -- Trailing spaces
}

-- =======================================
-- Search Behavior
-- =======================================
vim.opt.ignorecase = true        -- Case-insensitive by default
vim.opt.smartcase = true         -- Case-sensitive if uppercase used
vim.opt.hlsearch = true          -- Highlight matches
