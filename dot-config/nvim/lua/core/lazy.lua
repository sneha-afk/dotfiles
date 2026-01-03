-- .config/nvim/lua/core/lazy.lua
-- Initialization of the plugin system

-- If lazy.nvim not detected, ask if plugins should be installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.api.nvim_echo({
    { "Lazy.nvim not installed.\n", "WarningMsg" },
    { "Load plugin system? [y/N] ", "Question" },
  }, true, {})

  local input = vim.fn.getcharstr()
  if input:lower() ~= "y" then
    vim.api.nvim_echo({
      { "Plugin system disabled.\n",            "WarningMsg" },
      { "Run :Lazy bootstrap to enable later.", "MoreMsg" },
    }, true, {})
    return
  end
end

-- Bootstrap lazy.nvim
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)

-- Grabs all setup files in plugins
vim.keymap.set("n", "<leader>ll", "<cmd>Lazy<cr>", { desc = "Open Lazy plugin manager" })
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  defaults = {
    version = false,
    event = "VeryLazy",
  },
  rocks = { enabled = false },
  ui = {
    icons = {
      cmd = "⌘ ",
      config = "⚙️ ",
      event = "📅 ",
      ft = "📂 ",
      init = "🌱 ",
      keys = "🔑 ",
      plugin = "🔌 ",
      runtime = "⚡",
      require = "📦 ",
      source = "📄 ",
      start = "🚀 ",
      task = "📌 ",
      lazy = "💤 ",
    },
    border = "rounded",
    title = " lazy.nvim ",
    size = { width = 0.8, height = 0.85 },
  },
  checker = {          -- Detect changes to plugins
    enabled = false,
    frequency = 86400, -- Check every 86,400 seconds (24 hours)
    concurrency = 5,   -- Max parallel update checks
  },
  change_detection = { -- Detect changes to config
    enabled = true,
    notify = false,
  },
  performance = {
    cache = { enabled = true },
    rtp = {
      disabled_plugins = {
        "gzip",        -- Built-in compression (unneeded with modern SSDs)
        "netrwPlugin", -- Replaced by using other plugins
        "tarPlugin",   -- Rarely used archive handling
        "tohtml",      -- HTML export (security risk)
        "tutor",
        "zipPlugin",   -- Archive handling
        "rplugin",     -- Legacy remote plugin system
        "matchit",     -- Extended % matching (replaced by treesitter)
        "matchparen",
        "osc52",
      },
    },
  },
})
