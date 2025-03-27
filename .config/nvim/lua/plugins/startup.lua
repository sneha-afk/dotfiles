return {
  "echasnovski/mini.starter",
  version = "*",
  pin = true,
  event = "VimEnter",
  enabled = function()
    return vim.fn.argc() == 0
  end,
  dependencies = {
    "folke/lazy.nvim",
    "stevearc/oil.nvim",
    "williamboman/mason.nvim",
  },
  config = function()
    local starter = require("mini.starter")

    -- Get system username
    local username = os.getenv("USER") or os.getenv("USERNAME") or "User"

    -- Dynamic greeting based on time
    local hour = tonumber(os.date("%H"))
    local greeting
    if hour < 12 then
      greeting = "Good morning"
    elseif hour < 18 then
      greeting = "Good afternoon"
    else
      greeting = "Good evening"
    end

    starter.setup({
      evaluate_single = true,
      header = string.format(
        [[
███╗   ██╗██╗   ██╗██╗███╗   ███╗
████╗  ██║██║   ██║██║████╗ ████║
██╔██╗ ██║██║   ██║██║██╔████╔██║
██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝

%s, %s.
      ]],
        greeting,
        username
      ),
      items = {
        { section = "Actions", name = "New File", action = "ene | startinsert" },
        { section = "Actions", name = "File Browser", action = "Oil" },
        { section = "Actions", name = "Edit Config", action = "e $MYVIMRC" },
        { section = "Actions", name = "Reload Config", action = "source $MYVIMRC" },
        -- { section = "Actions", name = "Restore Session", action = "source Session.vim" },
        { section = "Actions", name = "Lazy.nvim: manage plugins", action = "Lazy" },
        { section = "Actions", name = "Mason: manage LSPs", action = "Mason" },
        { section = "Actions", name = "Quit", action = "qa" },

        starter.sections.recent_files(5, false), -- Recent files from current directory
        starter.sections.recent_files(5, true), -- Recent files from all directories
      },
      content_hooks = {
        starter.gen_hook.aligning("center", "center"),
        starter.gen_hook.adding_bullet("🡪 "),
      },
      footer = function()
        return os.date("%A, %B %d %Y") .. "; " .. os.date("%I:%M %p")
      end,
    })

    -- Improved Highlighting
    vim.api.nvim_set_hl(0, "MiniStarterHeader", { link = "Function" })
    vim.api.nvim_set_hl(0, "MiniStarterFooter", { link = "Comment" })
    vim.api.nvim_set_hl(0, "MiniStarterItem", { link = "Normal" })
    vim.api.nvim_set_hl(0, "MiniStarterItemPrefix", { link = "Boolean", bold = true })
    vim.api.nvim_set_hl(0, "MiniStarterItemBullet", { link = "Define" })
    vim.api.nvim_set_hl(0, "MiniStarterSection", { link = "TabLine" })
  end,
}
