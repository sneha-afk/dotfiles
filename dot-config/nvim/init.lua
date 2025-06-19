--[[
NEOVIM CONFIGURATION
------------------------------------
Where to store these files:
  Linux/macOS: ~/.config/nvim/init.lua
  Windows:     ~/AppData/Local/nvim/init.lua

See README for configuring information.
--]]

vim.g.mapleader = ","
vim.g.maplocalleader = "\\"
vim.uv = vim.uv or vim.loop

-- Taken from folke: override vim.keymap.set
-- Default to silent, non-recursive keymaps
local orig_keymap_set = vim.keymap.set
---@param mode string|string[]            -- Mode: e.g. "n", "i", or {"n", "v"}
---@param lhs string                      -- Key combination (e.g. "<leader>f")
---@param rhs string|function             -- Function, string command, or Lua expression
---@param opts? table|vim.keymap.set.Opts -- Options table (include "desc" for which-key)
---@diagnostic disable-next-line: duplicate-set-field
vim.keymap.set = function(mode, lhs, rhs, opts)
  opts = opts or {}
  -- ~= false -> if not explicitly set to false, then set to true
  opts.noremap = opts.noremap ~= false
  opts.silent = opts.silent ~= false
  orig_keymap_set(mode, lhs, rhs, opts)
end

---@type vim.diagnostic.Opts
local diagnostic_opts = {
  update_in_insert = true,
  virtual_text = {
    spacing = 2,
    source = "if_many",
  },
  severity_sort = true,
  float = {
    border = "rounded",
    header = "",
    title = " Diagnostics ",
    source = "if_many",
  },
}
vim.diagnostic.config(diagnostic_opts)

-- Disable provider warnings
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

-- Hack to work to launch in any environment that may load the UI later (e.g. WSL starts a server)
vim.api.nvim_create_autocmd("UIEnter", {
  desc = "Load GUI specific options (e.g. Neovide)",
  callback = function()
    if vim.g.neovide then
      vim.o.guifont = "Geist Mono,Symbols Nerd Font Mono:h10"
      vim.opt.belloff:append("all")

      local ctrl_key = vim.fn.has("mac") == 1 and "<D-" or "<C-"
      -- https://github.com/neovide/neovide/issues/1263#issuecomment-1972013043
      vim.keymap.set(
        { "n", "v", "s", "x", "o", "i", "l", "c", "t" },
        ctrl_key .. "v>",
        function() vim.api.nvim_paste(vim.fn.getreg("+"), true, -1) end,
        { desc = "Paste from clipboard" }
      )
      vim.keymap.set({ "n", "v" }, ctrl_key .. "c>", '"+y', { desc = "Copy to clipboard" })

      vim.keymap.set("n", "<leader>uf", function()
        vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
      end, { desc = "[U]I: toggle [f]ullscreen" })
    end
  end,
})

-- Load core configurations in this order
require("core.options")
require("core.filetypes")
require("core.commands")
require("core.keymaps")
require("core.terminal")

-- Ask if plugins should be installed if not already
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

-- Initialize plugin system
require("core.lazy")
