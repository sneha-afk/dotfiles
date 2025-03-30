-- .config/nvim/plugins/starter.lua
-- Minimal startup dashboard when no files are specifically opened

local HEADER_ART = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
]]

local function get_greeting()
  local hour = tonumber(os.date("%H"))
  if hour < 12 then
    return "Good morning"
  elseif hour < 18 then
    return "Good afternoon"
  else
    return "Good evening"
  end
end


return {
  "echasnovski/mini.starter",
  pin = true,
  event = function()
    return vim.fn.argc() == 0 and "VimEnter" or nil
  end,
  dependencies = {
    "folke/lazy.nvim",
    "stevearc/oil.nvim",
    "williamboman/mason.nvim",
    "folke/which-key.nvim",
  },
  config = function()
    local starter = require("mini.starter")
    local username = os.getenv("USER") or os.getenv("USERNAME") or "User"
    local greeting = get_greeting()

    starter.setup({
      evaluate_single = true,
      header = function()
        return HEADER_ART .. "\n" .. greeting .. ", " .. username .. ".\n"
      end,
      items = {
        { section = "Actions", name = "New File",                  action = "ene | startinsert" },
        { section = "Actions", name = "File Browser",              action = "Oil" },
        { section = "Actions", name = "Edit Config",               action = "e $MYVIMRC" },
        { section = "Actions", name = "Reload Config",             action = "source $MYVIMRC" },
        { section = "Actions", name = "Quit",                      action = "qa" },

        { section = "Tools",   name = "Lazy.nvim: manage plugins", action = "Lazy" },
        { section = "Tools",   name = "Mason: manage LSPs",        action = "Mason" },
        { section = "Tools",   name = "WhichKey: browse keymaps",  action = "WhichKey" },
        { section = "Tools",   name = "Check Health",              action = "checkhealth" },

        starter.sections.recent_files(5, true),   -- Files from current directory
        starter.sections.recent_files(10, false), -- Files from anywhere
      },
      content_hooks = {
        starter.gen_hook.aligning("center", "center"),
        starter.gen_hook.adding_bullet("🡪 "),
      },
      footer = function()
        local version = vim.version()
        local nvim_version = string.format("NVIM v%d.%d.%d", version.major, version.minor, version.patch)
        local curr_working_dir = vim.fn.fnamemodify(vim.fn.getcwd(), ":~")

        local sys_info = string.format(
          "%s • %s • %s",
          jit and jit.os or "System", -- OS name
          jit and jit.arch or "Arch", -- Architecture
          nvim_version
        )

        return string.format(
          "%s\n%s\n:%s",
          os.date("%A, %B %d %Y • %I:%M %p"),
          sys_info,
          curr_working_dir
        )
      end,
    })

    for hl, def in pairs({
      MiniStarterHeader = { link = "Title", bold = true },
      MiniStarterFooter = { link = "Comment", italic = true },
      MiniStarterItem = { link = "Normal" },
      MiniStarterItemBullet = { link = "Special", bold = true },
      MiniStarterItemPrefix = { link = "QuickFixLine", bold = true },
      MiniStarterSection = { link = "PmenuSel", bold = true },
      MiniStarterQuery = { link = "Keyword" },
    }) do
      vim.api.nvim_set_hl(0, hl, def)
    end
  end,
}
