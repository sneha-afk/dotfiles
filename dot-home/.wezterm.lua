-- ~/.wezterm.lua
-- sneha's wezterm configuration

local wezterm = require "wezterm"
local action = wezterm.action

local config = wezterm.config_builder()
local is_windows = wezterm.target_triple:find("windows")
-------------
---==== HELPERS
--- Check if an executable exists in the system PATH
---@param executable string Name of the executable
---@return boolean True if the executable exists
local function exe_exists(executable)
  local success
  if is_windows then
    success = wezterm.run_child_process({ "where.exe", "/Q", executable })
  else
    success = wezterm.run_child_process({ "bash", "-c", "command -v " .. executable .. " >/dev/null 2>&1" })
  end
  return success == true
end

---
if is_windows then
  config.default_prog = { exe_exists("pwsh") and "pwsh.exe" or "powershell.exe", "-NoLogo" }
  config.launch_menu = {
    { label = "Admin",          args = { "powershell.exe", "-NoLogo", "-Command", "Start-Process wt -Verb RunAs" } },
    { label = "Command Prompt", args = { "cmd.exe" } },
    { label = "Git Bash",       args = { "C:\\Program Files\\Git\\bin\\bash.exe", "-i", "-l" } },
  }
  config.window_background_opacity = 0.85
  config.win32_system_backdrop = "Mica"
end

config.front_end = "WebGpu"

--==== KEYBINDINGS
-- https:/wezterm.org/config/default-keys.html
config.leader    = { key = ",", mods = "CTRL", timeout_milliseconds = 2000 }
config.keys      = {
  { key = "l", mods = "ALT",          action = action.ShowLauncher },
  { key = "p", mods = "CTRL|SHIFT",   action = action.ActivateCommandPalette },
  { key = "q", mods = "CTRL|SHIFT",   action = action.QuitApplication },

  { key = "t", mods = "LEADER",       action = action.SpawnTab("CurrentPaneDomain") },
  { key = "x", mods = "LEADER",       action = action.CloseCurrentTab { confirm = true } },
  { key = "q", mods = "LEADER",       action = action.CloseCurrentPane { confirm = true } },
  { key = "r", mods = "LEADER",       action = action.ReloadConfiguration },
  { key = "f", mods = "LEADER",       action = action.Search("CurrentSelectionOrEmptyString") },
  { key = "z", mods = "LEADER",       action = action.TogglePaneZoomState },
  { key = "s", mods = "LEADER",       action = action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "v", mods = "LEADER",       action = action.SplitVertical({ domain = "CurrentPaneDomain" }) },

  -- fuzzy launchers
  { key = "t", mods = "LEADER|SHIFT", action = action.ShowLauncherArgs { flags = "TABS" } },
  { key = "p", mods = "LEADER|SHIFT", action = action.ShowLauncherArgs { flags = "COMMANDS" } },
  { key = "w", mods = "LEADER|SHIFT", action = action.ShowLauncherArgs { flags = "WORKSPACES" } },

  -- pane navigation (Ctrl+Alt+hjkl)
  { key = "h", mods = "CTRL|ALT",     action = action.ActivatePaneDirection("Left") },
  { key = "l", mods = "CTRL|ALT",     action = action.ActivatePaneDirection("Right") },
  { key = "k", mods = "CTRL|ALT",     action = action.ActivatePaneDirection("Up") },
  { key = "j", mods = "CTRL|ALT",     action = action.ActivatePaneDirection("Down") },

  -- quick pane selection
  { key = ",", mods = "LEADER",       action = action.PaneSelect },

  -- rotate panes within current tab
  { key = "o", mods = "LEADER",       action = action.RotatePanes("Clockwise") },
  { key = "O", mods = "LEADER|SHIFT", action = action.RotatePanes("CounterClockwise") },

  -- Copy when there is a selection, else send the Ctrl+C itself
  -- https://github.com/wezterm/wezterm/issues/606
  {
    key = "c",
    mods = "CTRL",
    action = wezterm.action_callback(function(window, pane)
      local sel = window:get_selection_text_for_pane(pane)
      if (not sel or sel == "") then
        window:perform_action(wezterm.action.SendKey { key = "c", mods = "CTRL" }, pane)
      else
        window:perform_action(wezterm.action { CopyTo = "ClipboardAndPrimarySelection" }, pane)
      end
    end),
  },
  { key = "v", mods = "CTRL",       action = action.PasteFrom("Clipboard") },

  -- Linux variations of copy-paste
  { key = "c", mods = "CTRL|SHIFT", action = action.CopyTo("Clipboard") },
  { key = "v", mods = "CTRL|SHIFT", action = action.PasteFrom("Clipboard") },
}

if is_windows then
  table.insert(config.keys, { key = "w", mods = "LEADER|ALT", action = action.SpawnTab { DomainName = "WSL:Ubuntu" } })
end

--==== APPEARANCE
-- WezTerm comes with JetBrains Mono, symbols, and emojis; but added after this list,
-- so keep JetBrains Mono above the emoji set (always put fonts above emojis)
config.font              = wezterm.font_with_fallback({
  "Geist Mono",
  "JetBrains Mono",
  "Segoe UI Emoji",
  "Symbols Nerd Font Mono",
})
config.font_size         = 10
config.harfbuzz_features = { "calt=1", "clig=0", "liga=0" }

config.color_scheme      = "iceberg-dark"
local scheme             = wezterm.color.get_builtin_schemes()[config.color_scheme or "Default Dark (base16)"]

--== COLOR HELPERS
local bg                 = scheme.background or "#1e1e2e"
local fg                 = scheme.foreground or "#c0caf5"
local accent             = scheme.brights and scheme.brights[2] or fg

--- Adjust color brightness by percentage (-100 to 100)
---@param hex string Hex color code
---@param percent number Percentage adjustment (-100 to 100)
---@return string Adjusted hex color
local function adjust_brightness(hex, percent)
  local r, g, b = hex:match("#?(%x%x)(%x%x)(%x%x)")
  if not r or not percent then return hex end

  local factor = 1 + (percent / 100)
  local function clamp(val)
    return math.floor(math.max(0, math.min(255, tonumber(val, 16) * factor)))
  end

  return string.format("#%02x%02x%02x", clamp(r), clamp(g), clamp(b))
end

--- Check if a color is dark based on relative luminance
---@param hex string Hex color code
---@return boolean True if color is dark
local function is_dark_theme(hex)
  if not hex then return true end
  local r, g, b = hex:match("#?(%x%x)(%x%x)(%x%x)")
  if not r then return true end
  local luminance = (tonumber(r, 16) * 0.299 + tonumber(g, 16) * 0.587 + tonumber(b, 16) * 0.114) / 255
  return luminance < 0.5
end

local is_dark            = is_dark_theme(bg)

-- Adjustment step values (positive = lighter, negative = darker)
local step_xsmall        = is_dark and 10 or -10
local step_small         = is_dark and 15 or -15
local step_medium        = is_dark and 30 or -30
local step_large         = is_dark and 50 or -50
local step_xlarge        = is_dark and 75 or -75

local step_neg_small     = is_dark and -15 or 15
local step_neg_medium    = is_dark and -30 or 30
local step_neg_large     = is_dark and -50 or 50

--== TAB BAR
config.colors            = {
  tab_bar = {
    active_tab = {
      bg_color = adjust_brightness(bg, is_dark and step_xlarge or step_xsmall),
      fg_color = fg,
    },
    inactive_tab = {
      bg_color = adjust_brightness(bg, is_dark and step_neg_medium or step_medium),
      fg_color = adjust_brightness(fg, step_neg_small),
    },
    inactive_tab_hover = {
      bg_color = adjust_brightness(bg, step_small),
      fg_color = fg,
    },
    new_tab = {
      bg_color = adjust_brightness(bg, step_small),
      fg_color = fg,
    },
    new_tab_hover = {
      bg_color = adjust_brightness(bg, step_neg_small),
      fg_color = fg,
    },
  },
  split = fg,
}

config.use_fancy_tab_bar = true
config.tab_max_width     = 24

---Bundled with Wezterm: https://www.nerdfonts.com/cheat-sheet
---@param text string Search against for an icon
---@return string Icon for the text (Nerd Font Symbol)
local function get_icon(text)
  local t = text:lower()
  if t:find("local") then return " " end
  if t:find("nvim") then return " " end
  if t:find("git") then return " " end
  if t:find("ubuntu") then return " " end
  if t:find("debian") then return " " end
  if t:find("arch") then return " " end
  if t:find("fedora") then return " " end
  if t:find("wsl") then return " " end
  if t:find("bash") then return " " end
  if t:find("zsh") then return " " end
  if t:find("pwsh") then return " " end
  if t:find("powershell") then return "󰨊 " end
  if t:find("cmd") then return " " end
  if t:find("wezterm") then return "" end
  if t:find("ssh") then return "󰣀 " end
  return " "
end

wezterm.on("format-tab-title", function(tab)
  local title = tab.active_pane.title or "shell"
  -- local prog  = tab.active_pane.foreground_process_name:lower() or ""

  title       = title:gsub(".*[\\/]", "") -- strip path
  title       = title:gsub("%.exe$", "")  -- remove .exe

  if title:find("wsl") then title = "wsl" end

  local is_admin = false
  if tab.active_pane.title:find("Administrator:") or
  tab.active_pane.title:find("root") or
  tab.active_pane.title:find("#") then
    is_admin = true
  end

  local idx = (tab.tab_index or 0) + 1
  local icon = get_icon(title)
  local tab_label = string.format("%s  %d: %s ", icon, idx, title)
  if is_admin then tab_label = string.format(" 󰒙  %s", tab_label) end
  return tab_label
end)

--==== WINDOW
config.initial_cols         = 128
config.initial_rows         = 32

config.inactive_pane_hsb    = { saturation = 0.85, brightness = 0.75 }

config.max_fps              = 120
config.default_cursor_style = "SteadyBar"
config.enable_scroll_bar    = true
config.scrollback_lines     = 10000

config.window_decorations   = "RESIZE"
config.window_frame         = {
  active_titlebar_bg = adjust_brightness(bg, step_medium),
  inactive_titlebar_bg = adjust_brightness(bg, step_large),
  font = wezterm.font_with_fallback({
    { family = "Inter",  weight = "Medium" },
    { family = "Geist",  weight = "Medium" },
    { family = "Roboto", weight = "Bold" }, -- default
  }),
}
config.window_padding       = {
  left = "0.75cell",
  right = "0.5cell",
  top = "0.5cell",
  bottom = "0.25cell",
}

wezterm.on("update-right-status", function(window, pane)
  local cells = {}

  -- leader mode indicator
  if window:leader_is_active() then
    table.insert(cells, { Background = { Color = accent } })
    table.insert(cells, { Foreground = { Color = bg } })
    table.insert(cells, { Text = "  󱐋 LEADER  " })
    table.insert(cells, { Background = { Color = bg } })
    table.insert(cells, { Foreground = { Color = accent } })
  else
    table.insert(cells, { Background = { Color = bg } })
    table.insert(cells, { Foreground = { Color = fg } })
  end

  local time = wezterm.strftime("%I:%M %p")
  local domain = pane:get_domain_name():lower()

  table.insert(cells, { Text = " ┊  " })
  table.insert(cells, { Text = get_icon(domain) })
  table.insert(cells, { Text = " ┊  " })
  table.insert(cells, { Text = time })
  table.insert(cells, { Text = "  " })

  window:set_right_status(wezterm.format(cells))
end)

config.adjust_window_size_when_changing_font_size = false

-------------
return config
