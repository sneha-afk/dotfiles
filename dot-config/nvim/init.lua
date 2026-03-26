--[[
sneha's neovim config
------------------------------------
  Linux:    ~/.config/nvim/init.lua
  Windows:  ~/AppData/Local/nvim/init.lua
--]]
vim.loader.enable()

vim.g.mapleader = ","
vim.g.maplocalleader = "\\"
vim.uv = vim.uv or vim.loop

vim.g.is_windows = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
vim.g.is_ssh = vim.env.SSH_CLIENT or vim.env.SSH_TTY

vim.g.is_wezterm = vim.env.TERM_PROGRAM == "WezTerm"
vim.g.is_ghostty = vim.env.TERM_PROGRAM == "ghostty"

-- Should (non-essential) icons be used?
-- Set to false explicitly to override auto-detection (i.e. keep as true if patched font/symbols are installed)
vim.g.use_icons_manual = true

vim.g.use_icons = (vim.g.use_icons_manual ~= false) and (
  vim.g.is_wezterm
  or vim.g.is_ghostty
  or vim.g.neovide
  or vim.fn.has("gui_running") == 1
  or (vim.env.TERM or ""):find("kitty", 1, true)
)

-- Picker to use in dependency tables
vim.g.picker_source = "folke/snacks.nvim"

if vim.g.is_windows then
  local shell = vim.fn.executable("pwsh") == 1 and "pwsh"
      or vim.fn.executable("powershell") == 1 and "powershell"
      or "cmd"
  vim.opt.shell = shell

  if shell ~= "cmd" then
    vim.opt.shellcmdflag =
    "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command $PSStyle.OutputRendering='PlainText';"
    vim.opt.shellredir = "2>&1 | Out-File -Encoding utf8 %s; exit $LastExitCode"
    vim.opt.shellpipe = "2>&1 | Out-File -Encoding utf8 %s; exit $LastExitCode"
    vim.opt.shellquote = ""
    vim.opt.shellxquote = ""
  else
    vim.opt.shellcmdflag = "/s /c"
  end
end

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

-- Disable provider warnings
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

---@type vim.diagnostic.Opts
local diagnostic_opts = {
  update_in_insert = false,
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

require("core.options")
require("core.keymaps")
require("core.filetypes")
require("core.commands")

-- Hack to work to launch in any environment that may load the UI later (e.g. WSL starts a server)
vim.api.nvim_create_autocmd("UIEnter", {
  desc = "Load GUI specific options (e.g. Neovide)",
  once = true,
  callback = function()
    if vim.g.neovide then require("core.neovide") end
  end,
})

require("core.lazy")
