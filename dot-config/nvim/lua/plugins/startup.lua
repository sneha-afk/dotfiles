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
    if hour < greeting.max then return greeting.emoji .. " " .. greeting.msg end
  end
  return "Hello"
end

return {
  "echasnovski/mini.starter",
  event = function() return vim.fn.argc() == 0 and "VimEnter" or nil end,
  version = false,
  dependencies = {
    vim.g.picker_source,
    "nvim-mini/mini.sessions",
  },
  config = function()
    local starter = require("mini.starter")
    local username = os.getenv("USER") or os.getenv("USERNAME") or "User"
    local greeting = get_greeting()

    starter.setup({
      header = function() return HEADER_ART .. "\n" .. greeting .. ", " .. username .. ".\n" end,
      items = {
        { section = "Actions", name = "New File",     action = "ene | startinsert" },
        { section = "Actions", name = "Browse files", action = function() Snacks.explorer() end },
        { section = "Actions", name = "Find files",   action = require("core.utils.fileops").snacks_find_files },
        { section = "Actions", name = "Smart find",   action = function() Snacks.picker.smart() end },
        { section = "Actions", name = "Search",       action = function() Snacks.picker.grep() end },
        { section = "Actions", name = "Quit",         action = "qa" },

        starter.sections.sessions(5, true),
        starter.sections.recent_files(5, false),

        { section = "Tools", name = "Edit Config",               action = "e $MYVIMRC" },
        { section = "Tools", name = "Check Health",              action = "checkhealth" },
        { section = "Tools", name = "Lazy.nvim: manage plugins", action = "Lazy" },
      },
      content_hooks = {
        starter.gen_hook.aligning("center", "center"),
        starter.gen_hook.adding_bullet("⪧ "),
      },
      footer = function()
        local version = vim.version()
        local nvim_version = string.format("NVIM v%d.%d.%d", version.major, version.minor, version.patch)
        local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":~")

        return string.format("%s • %s\n%s", os.date("%A, %B %d %Y • %I:%M %p"), nvim_version, cwd)
      end,
    })
  end,
}
