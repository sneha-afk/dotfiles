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
  local greetings = {
    { max = 5, msg = "Sleep well", emoji = "🌙" },
    { max = 12, msg = "Good morning", emoji = "🌅" },
    { max = 18, msg = "Good afternoon", emoji = "🌞" },
    { max = 22, msg = "Good evening", emoji = "🌆" },
    { max = 24, msg = "Good night", emoji = "✨" },
  }

  for _, greeting in ipairs(greetings) do
    if hour < greeting.max then
      return greeting.emoji .. " " .. greeting.msg
    end
  end
  return "Hello"
end


return {
  "echasnovski/mini.starter",
  pin = true,
  event = function()
    return vim.fn.argc() == 0 and "VimEnter" or nil
  end,
  dependencies = {
    "folke/lazy.nvim",
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    local starter = require("mini.starter")
    local username = os.getenv("USER") or os.getenv("USERNAME") or "User"
    local greeting = get_greeting()

    starter.setup({
      header = function()
        return HEADER_ART .. "\n" .. greeting .. ", " .. username .. ".\n"
      end,
      items = {
        { section = "Actions", name = "New File",                  action = "ene | startinsert" },
        { section = "Actions", name = "File Browser",              action = "Telescope file_browser" },
        { section = "Actions", name = "Search",                    action = "Telescope live_grep" },
        { section = "Actions", name = "Quit",                      action = "qa" },

        { section = "Tools",   name = "Edit Config",               action = "e $MYVIMRC" },
        { section = "Tools",   name = "Lazy.nvim: manage plugins", action = "Lazy" },
        { section = "Tools",   name = "Check Health",              action = "checkhealth" },

        starter.sections.recent_files(10, false),
      },
      content_hooks = {
        starter.gen_hook.aligning("center", "center"),
        starter.gen_hook.adding_bullet("🡒 "),
      },
      footer = function()
        local version = vim.version()
        local nvim_version = string.format("NVIM v%d.%d.%d", version.major, version.minor, version.patch)
        local curr_working_dir = vim.fn.fnamemodify(vim.fn.getcwd(), ":~")

        return string.format(
          "%s • %s\n%s",
          os.date("%A, %B %d %Y • %I:%M %p"),
          nvim_version,
          curr_working_dir
        )
      end,
    })

    vim.api.nvim_set_hl(0, "MiniStarterHeader", { link = "Define" })
    vim.api.nvim_set_hl(0, "MiniStarterFooter", { link = "LineNr" })
    vim.api.nvim_set_hl(0, "MiniStarterQuery", { link = "IncSearch" })
    vim.api.nvim_set_hl(0, "MiniStarterItemPrefix", { link = "Keyword" })
    vim.api.nvim_set_hl(0, "MiniStarterItemBullet", { link = "LineNr" })
    vim.api.nvim_set_hl(0, "MiniStarterCurrent", { link = "CursorLine" })
    vim.api.nvim_set_hl(0, "MiniStarterSection", { link = "MsgSeparator" })
  end,
}
