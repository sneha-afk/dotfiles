-- .config/nvim/lua/core/lazy.lua
-- Initialization of the plugin system

if vim.g.lazy_nvim_loaded then return end
vim.g.lazy_nvim_loaded = true

-- Bootstrap lazy.nvim plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
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
  ui = {
    icons = {
      cmd = "⌘ ",
      config = "🛠 ",
      event = "📅 ",
      ft = "📂 ",
      init = "⚙ ",
      keys = "🔑 ",
      plugin = "🔌 ",
      runtime = "💻 ",
      require = "🌙 ",
      source = "📄 ",
      start = "🚀 ",
      task = "📌 ",
      lazy = "💤 ",
    },
    border = "rounded",
    title = " lazy.nvim ",
    backdrop = 100,
  },
  checker = {
    enabled = true,    -- Enable plugin version checking
    frequency = 86400, -- Check every 86,400 seconds (24 hours)
    concurrency = 5    -- Max parallel update checks
  },
  change_detection = {
    enabled = true, -- Monitor plugin files for changes
    notify = false, -- Disable "plugins modified" alerts
  },
  performance = {
    cache = {
      enabled = true,
      path = vim.fn.stdpath("cache") .. "/lazy/cache",
      reset_on_startup = vim.fn.has("nvim-0.9.0") == 1 -- Auto-clear after Neovim updates
    },
    rtp = {
      disabled_plugins = {
        "gzip",        -- Built-in compression (unneeded with modern SSDs)
        "netrwPlugin", -- Replaced by using other plugins
        "tarPlugin",   -- Rarely used archive handling
        "tohtml",      -- HTML export (security risk)
        "zipPlugin",   -- Archive handling
        "rplugin"      -- Legacy remote plugin system
      },
    },
  },
})
