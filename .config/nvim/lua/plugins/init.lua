-- .config/nvim/lua/plugins/init.lua
-- Initialization of the plugin system

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

require("lazy").setup({
  { import = "plugins.startup" },
  { import = "plugins.ui" },
  { import = "plugins.editor" },
  { import = "plugins.file_tree" },
  { import = "plugins.lsp.init" },
}, {
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
      source = "📄 ",
      start = "🚀 ",
      task = "📌 ",
      lazy = "💤 ",
      list = { "●", "➜", "★", "-" }
    },
    border = "rounded",
    title = " lazy.nvim ",
    backdrop = 100,
    browser = {
      tf = "🌐 ", -- Browser title prefix
      open = "🖥️ " -- Open in browser icon
    },
    -- Progress indicators
    throttle = 10,
    custom_keys = {
      ["<localleader>l"] = function(plugin)
        print("[!] Plugin info: " .. plugin.name)
      end,
    },
  },
  -- Installation settings: auto-install missing plugins
  install = {
    missing = true,
    colorscheme = { "habamax", "slate" },
    -- Progress styling
    progress = {
      title = "[INSTALLING]",
      done = "[✓]",
      style = {
        header = "▔▔▔▔▔",
        footer = "▁▁▁▁▁",
      },
    },
  },
  checker = {
    enabled = true,      -- Enable plugin version checking
    frequency = 86400,   -- Check every 86,400 seconds (24 hours)
    check_pinned = true, -- Verify even pinned plugins (version-locked)
    concurrency = 5      -- Max parallel update checks
  },
  change_detection = {
    enabled = true, -- Monitor plugin files for changes
    notify = false, -- Disable "plugins modified" alerts
    debounce = 1000 -- Wait 1 second after last file change
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
    gc = {
      threshold = 1024 * 1024, -- Trigger GC when memory grows beyond 1MB
      aggressive = false       -- Don't force full GC (avoids UI freezes)
    },
  },
})
