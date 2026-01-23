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

vim.g.is_wezterm = vim.fn.getenv("TERM_PROGRAM") == "WezTerm"

-- Swap out pickers and any plugins using them
vim.g.picker_source = "folke/snacks.nvim"

-- Should (non-essential) icons be used?
-- Manually set to true/false to override auto-detection (e.g. installed patched font)
vim.g.use_icons_manual = true

-- Fallbacks to manual setting above
vim.g.use_icons = vim.g.is_wezterm or vim.g.neovide or vim.fn.has("gui_running") == 1
    or (function()
      local term = os.getenv("TERM") or ""
      return term:find("kitty") or term:find("ghostty")
    end)()
    or vim.g.use_icons_manual

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

require("core.options")
require("core.keymaps")
require("core.lazy")
require("core.filetypes")
require("core.commands")
require("core.terminal")

-- Hack to work to launch in any environment that may load the UI later (e.g. WSL starts a server)
vim.api.nvim_create_autocmd("UIEnter", {
  desc = "Load GUI specific options (e.g. Neovide)",
  callback = function()
    if vim.g.neovide then
      require("core.neovide")
    end
  end,
})
