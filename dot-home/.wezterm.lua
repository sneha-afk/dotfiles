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
  local cmd
  if is_windows then
    cmd = { "where.exe", "/Q", executable }
  else
    cmd = { "bash", "-c", "command -v " .. executable .. " >/dev/null 2>&1" }
  end
  return wezterm.run_child_process(cmd)
end

---
if is_windows then
  config.default_prog = { exe_exists("pwsh") and "pwsh.exe" or "powershell.exe", "-NoLogo" }
  config.launch_menu = {
    { label = "Command Prompt", args = { "cmd.exe" } },
    { label = "Git Bash",       args = { "C:\\Program Files\\Git\\bin\\bash.exe", "-i", "-l" } },
  }
end

config.front_end = "WebGpu"

--==== KEYBINDINGS
-- https:/wezterm.org/config/default-keys.html
config.leader    = { key = ",", mods = "CTRL", timeout_milliseconds = 2000 }
config.keys      = {
  { key = "l",          mods = "ALT",        action = action.ShowLauncher },
  { key = "p",          mods = "CTRL|SHIFT", action = action.ActivateCommandPalette },
  { key = "q",          mods = "CTRL|SHIFT", action = wezterm.action.QuitApplication },

  { key = "c",          mods = "CTRL|SHIFT", action = action.CopyTo("Clipboard") },
  { key = "v",          mods = "CTRL|SHIFT", action = action.PasteFrom("Clipboard") },

  { key = "t",          mods = "LEADER",     action = action.SpawnTab("CurrentPaneDomain") },
  { key = "x",          mods = "LEADER",     action = action.CloseCurrentTab { confirm = true } },
  { key = "q",          mods = "LEADER",     action = action.CloseCurrentPane { confirm = true } },
  { key = "r",          mods = "LEADER",     action = action.ReloadConfiguration },
  { key = "f",          mods = "LEADER",     action = action.Search("CurrentSelectionOrEmptyString") },
  { key = "z",          mods = "LEADER",     action = action.TogglePaneZoomState },
  { key = "s",          mods = "LEADER",     action = action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "v",          mods = "LEADER",     action = action.SplitVertical({ domain = "CurrentPaneDomain" }) },

  -- pane navigation (Ctrl+Alt+hjkl)
  { key = "h",          mods = "CTRL|ALT",   action = action.ActivatePaneDirection("Left") },
  { key = "l",          mods = "CTRL|ALT",   action = action.ActivatePaneDirection("Right") },
  { key = "k",          mods = "CTRL|ALT",   action = action.ActivatePaneDirection("Up") },
  { key = "j",          mods = "CTRL|ALT",   action = action.ActivatePaneDirection("Down") },

  -- resize panes (Ctrl+Shift+Arrow)
  { key = "LeftArrow",  mods = "CTRL|SHIFT", action = action.AdjustPaneSize({ "Left", 3 }) },
  { key = "RightArrow", mods = "CTRL|SHIFT", action = action.AdjustPaneSize({ "Right", 3 }) },
  { key = "UpArrow",    mods = "CTRL|SHIFT", action = action.AdjustPaneSize({ "Up", 1 }) },
  { key = "DownArrow",  mods = "CTRL|SHIFT", action = action.AdjustPaneSize({ "Down", 1 }) },
}

if is_windows then
  table.insert(config.keys, { key = "w", mods = "LEADER", action = action.SpawnTab { DomainName = "WSL:Ubuntu" } })
end

--==== APPEARANCE
config.font         = wezterm.font_with_fallback({ "Geist Mono", "Segoe UI Emoji" })
config.font_size    = 10

config.color_scheme = "iceberg-dark"
local scheme        = wezterm.color.get_builtin_schemes()[config.color_scheme or "Default Dark (base16)"]

--== COLOR HELPERS
local bg            = scheme.background or "#1e1e2e"
local fg            = scheme.foreground or "#c0caf5"

--- Adjust color brightness by percentage (-100 to 100)
---@param hex string Hex color code
---@param percent number Percentage adjustment (-100 to 100)
---@return string Adjusted hex color
local function adjust_brightness(hex, percent)
  local r, g, b = hex:match("#?(%x%x)(%x%x)(%x%x)")
  if not r then return hex end

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
  local r, g, b = hex:match("#?(%x%x)(%x%x)(%x%x)")
  local luminance = (tonumber(r, 16) * 0.299 + tonumber(g, 16) * 0.587 + tonumber(b, 16) * 0.114) / 255
  return luminance < 0.5
end

local is_dark            = is_dark_theme(bg)
local brighter           = is_dark and 15 or -15
local brighter_2x        = is_dark and 30 or -30
local darker             = is_dark and -15 or 15
local darker_2x          = is_dark and -30 or 30
local brighter_hover     = is_dark and 5 or -5
local darker_hover       = is_dark and -5 or 5

--== TAB BAR
config.colors            = {
  tab_bar = {
    background = adjust_brightness(bg, darker_2x),
    active_tab = { bg_color = adjust_brightness(bg, brighter_2x), fg_color = fg },
    inactive_tab = { bg_color = adjust_brightness(bg, darker_2x), fg_color = adjust_brightness(fg, -15) },
    inactive_tab_hover = { bg_color = adjust_brightness(bg, darker_hover), fg_color = adjust_brightness(fg, 5) },
    new_tab = { bg_color = adjust_brightness(bg, darker_2x), fg_color = adjust_brightness(fg, -25) },
    new_tab_hover = { bg_color = adjust_brightness(bg, brighter_hover), fg_color = fg },
  },
}

config.use_fancy_tab_bar = true
config.tab_max_width     = 24

wezterm.on("format-tab-title", function(tab)
  local title = tab.active_pane.title
  title = title:gsub(".*[\\/]", "") -- strip path
  if title == "" then title = "shell" end
  return title
end)

--==== WINDOW
config.initial_cols         = 120
config.initial_rows         = 28

config.inactive_pane_hsb    = { saturation = 0.9, brightness = 0.7 }

config.max_fps              = 120
config.default_cursor_style = "BlinkingBar"

config.window_decorations   = "RESIZE"
config.window_frame         = {
  active_titlebar_bg = adjust_brightness(bg, brighter),
  inactive_titlebar_bg = adjust_brightness(bg, darker),
  font = wezterm.font("Geist"),
}

local leader_mode_colors    = {
  bg_color = adjust_brightness(bg, brighter_2x),
  fg_color = fg,
  accent   = adjust_brightness(fg, 25),
}

wezterm.on("update-right-status", function(window, _)
  local status = {}

  if window:leader_is_active() then
    table.insert(status, { Background = { Color = leader_mode_colors.bg_color } })
    table.insert(status, { Foreground = { Color = leader_mode_colors.accent } })
    table.insert(status, { Text = " 🟢 LEADER " })
  end

  window:set_right_status(wezterm.format(status))
end)

config.adjust_window_size_when_changing_font_size = false

-------------
return config
