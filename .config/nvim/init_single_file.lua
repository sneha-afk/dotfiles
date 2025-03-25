-- Neovim Configuration
-- File location: ~/.config/nvim/init.lua (Linux/macOS)
--                ~/AppData/Local/nvim/init.lua (Windows)

-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

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

-- ===================================================================
-- Leader Key Setup
-- ===================================================================
vim.g.mapleader = ","

vim.keymap.set("n", "<leader>", function()
  vim.notify("Unmapped leader key", vim.log.levels.ERROR)
end, { desc = "Fallback for unmapped leader keys" })

-- ===================================================================
-- Plugin Management
-- ===================================================================
require("lazy").setup({
  {
    "vague2k/vague.nvim",
    config = function()
      vim.cmd.colorscheme("vague")
    end
  },

  -- Status Line
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",
          icons_enabled = false,    -- Minimal look, only text
        },
        sections = {
          lualine_a = {'mode'},                      -- Left: Mode (Normal/Insert)
          lualine_b = {'filename', 'readonly'},      -- Left: Filename + RO flag
          lualine_c = {
            'branch',                                -- Git branch name
            'diff',                                  -- Git changes (+,~,-)
            'diagnostics'                            -- Optional: LSP errors/warnings
          },
          lualine_x = {'filetype'},                  -- Right: Filetype
          lualine_y = {'progress'},                  -- Right: Percentage
          lualine_z = {'location'}                   -- Right: Line:Column
        },
        -- Inactive windows: only show filename and location
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {'filename'},
          lualine_x = {'location'},
          lualine_y = {},
          lualine_z = {}
        }
      })
      vim.opt.showmode = false      -- Disable extra mode indicator
    end,
  },

  -- File Tree
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    config = function()
      require("nvim-tree").setup({
        sort = { sorter = "case_sensitive" },
        renderer = {
          add_trailing = true,    -- Add trailing slash to folders
          icons = {
            webdev_colors = false,
            show = {
              file = false,
              folder = false,
              folder_arrow = false,
              git = false,
            },
          },
          indent_markers = {
            enable = true,        -- Show faint vertical guides
            icons = { corner = "└" }
          },
        },
        filters = {
          dotfiles = true,        -- Show dotfiles
          custom = { "^.git$" },  -- Hide .git directory
          exclude = { ".env" }    -- Exclusions to any filters
        },
        hijack_cursor = true,     -- Keep cursor on tree when opening
        update_focused_file = {
          enable = true,          -- Auto focus current file
          update_root = true      -- Update root after going to another folder
        },
        log = {
          enable = false,         -- Disable logging for performance
          types = { diagnostics = false }
        },
      })
    end,
  },

  -- Pair Completion
  { "windwp/nvim-autopairs", event = "InsertEnter", config = true },

  -- Commenting
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup({
        toggler = { line = '<leader>cc', block = '<leader>bc' },
        opleader = { line = '<leader>c', block = '<leader>b' },
      })
    end,
  },
}, {
  -- Automatically manage plugins
  install = { missing = true },
  checker = { 
    enabled = true,
    notify = false
  },
  change_detection = {
    enabled = true,
    notify = false
  }
})

-- ===================================================================
-- Keymappings
-- ===================================================================
-- n for opening file tree
vim.keymap.set("n", "<leader>n", ":NvimTreeFocus<CR>", { noremap = true, silent = true })

-- t for terminal, vt for vertical terminal
vim.keymap.set('n', '<leader>t', ':split | terminal<CR>i', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>vt', ':vsplit | terminal<CR>i', { noremap = true, silent = true })

-- Esc -> back to normal mode in terminal
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", {noremap = true, silent = true})

-- =======================================
-- Indentation and Tabs
-- =======================================
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
vim.opt.breakindent = true          -- Indent wrapped lines
vim.opt.breakindentopt = 'shift:4'  -- Indent by 4 spaces

-- =======================================
-- Whitespace Visualization
-- =======================================
vim.opt.list = true                 -- Show invisible chars
vim.opt.listchars = {
  tab = '▸ ',                       -- Tab characters
  trail = '·'                       -- Trailing spaces
}

-- =======================================
-- Search Behavior
-- =======================================
vim.opt.ignorecase = true        -- Case-insensitive by default
vim.opt.smartcase = true         -- Case-sensitive if uppercase used
vim.opt.hlsearch = true          -- Highlight matches

-- ===================================================================
-- Filetype Specific Settings
-- ===================================================================
vim.api.nvim_create_autocmd("FileType", {
  pattern = "c",
  command = "setlocal cindent"
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = {"make", "go"},
  command = "setlocal noexpandtab"
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = {"markdown", "tex"},
  command = "setlocal spell wrap linebreak"
})

-- ===================================================================
-- Terminal Settings
-- ===================================================================
-- On opening terminal, disable line numbers and clean gutter space
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  command = "setlocal nonumber norelativenumber signcolumn=no"
})

-- Windows Terminal Cursor Shaping
if vim.env.WT_SESSION then
  vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"
end
