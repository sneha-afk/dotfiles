-- ~/.wezterm.lua

local wezterm    = require "wezterm" ---@type Wezterm
local config     = wezterm.config_builder() ---@type Config
local action     = wezterm.action ---@type Action

local IS_WINDOWS = wezterm.target_triple:find("windows", 1, true) ~= nil
local IS_LINUX   = wezterm.target_triple:find("linux", 1, true) ~= nil
local IS_MAC     = wezterm.target_triple:find("darwin", 1, true) ~= nil

--- Checks whether an executable is resolvable on PATH.
--- @param executable string
--- @return boolean
local function check_exe(executable)
  local cmd = IS_WINDOWS and { "where.exe", "/Q", executable }
      or { "sh", "-c", "command -v " .. executable .. " >/dev/null 2>&1" }
  local success = wezterm.run_child_process(cmd)
  return success == true
end

local HAS_WSL = IS_WINDOWS and check_exe("wsl")

--- Adjusts a hex color by a percentage factor.
--- @param hex string  Hex color string in `#rrggbb` format.
--- @param percent number  Adjustment factor; negative darkens, positive lightens.
--- @return string
local function adjust(hex, percent)
  local r = tonumber(hex:sub(2, 3), 16)
  local g = tonumber(hex:sub(4, 5), 16)
  local b = tonumber(hex:sub(6, 7), 16)
  local factor = 1 + (percent / 100)

  local function clamp(val)
    return math.floor(math.min(255, math.max(0, val * factor)))
  end

  return string.format("#%02x%02x%02x", clamp(r), clamp(g), clamp(b))
end

--- Returns true if the given hex color has a perceived luminance below 0.5 (ITU-R BT.601).
--- @param hex string  Hex color string in `#rrggbb` format.
--- @return boolean
local function is_dark(hex)
  local r = tonumber(hex:sub(2, 3), 16)
  local g = tonumber(hex:sub(4, 5), 16)
  local b = tonumber(hex:sub(6, 7), 16)
  if not r then return true end

  local lum = (r * 0.299 + g * 0.587 + b * 0.114) / 255
  return lum < 0.5
end

local base_bg       = "#161821"
local base_fg       = "#d2d4de"
local base_accent   = "#e98989"
local dark          = is_dark(base_bg)
local COLORS        = {
  bg                = base_bg,
  fg                = base_fg,
  accent            = base_accent,
  active_titlebar   = adjust(base_bg, dark and 20 or -20),
  inactive_titlebar = base_bg,
  tab_active_bg     = adjust(base_bg, dark and 80 or -50),
  tab_active_fg     = base_fg,
  tab_inactive_bg   = adjust(base_bg, dark and -25 or 25),
  tab_inactive_fg   = adjust(base_fg, dark and -50 or 50),
  hover_bg          = adjust(base_bg, dark and 40 or -40),
}

local STATE         = {
  icon_cache   = {},
  status_cache = { leader = false },
}

local LEADER_STATUS = wezterm.format({
  { Background = { Color = COLORS.accent } }, { Foreground = { Color = COLORS.bg } },
  { Text = "  󱐋 LEADER  " },
  -- { Background = { Color = COLORS.bg } }, { Foreground = { Color = COLORS.fg } },
})

-- Refresh expensive computations only on config reload or window launch
local function refresh_state()
  STATE.icon_cache          = {}
  STATE.status_cache.leader = nil
end
wezterm.on("window-config-reloaded", refresh_state)

--==============================================================================
config.front_end = "WebGpu"
config.max_fps = 60

if IS_WINDOWS then
  config.default_prog = { check_exe("pwsh") and "pwsh.exe" or "powershell.exe", "-NoLogo" }
elseif IS_LINUX then
  config.default_prog = { "bash", "-l" }
elseif IS_MAC then
  config.default_prog = { check_exe("zsh") and "zsh" or "bash", "-l" }
end

config.initial_cols = 128
config.initial_rows = 32

config.leader = { key = ",", mods = "CTRL", timeout_milliseconds = 2000 }
config.keys = {
  -- global actions
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

  -- Linux-style copy-paste
  { key = "c", mods = "CTRL|SHIFT", action = action.CopyTo("Clipboard") },
  { key = "v", mods = "CTRL|SHIFT", action = action.PasteFrom("Clipboard") },
}

if HAS_WSL then
  table.insert(config.keys, { key = "w", mods = "LEADER|ALT", action = action.SpawnTab { DomainName = "WSL:Ubuntu" } })
end

--==============================================================================
local ICONS = {
  ["local"]  = " ",
  ssh        = "󰣀 ",
  nvim       = " ",
  git        = " ",
  ubuntu     = " ",
  debian     = " ",
  arch       = " ",
  fedora     = " ",
  wsl        = " ",
  bash       = " ",
  zsh        = " ",
  pwsh       = " ",
  powershell = "󰨊 ",
  cmd        = " ",
  wezterm    = " ",
}

local ICONS_FUZZY_KEYS = { -- for composite titles/domains (e.g. "WSL:Ubuntu", "ssh user@host")
  "ubuntu", "debian", "arch", "fedora",
  "wsl", "ssh",
}

--- Returns the Nerd Font icon glyph for a process or domain name, with memoization.
--- Falls back to a space glyph if no match is found.
--- @param text string
--- @return string
local function get_icon(text)
  if not text or text == "" then return " " end

  local lower = text:lower()
  local cached = STATE.icon_cache[lower]
  if cached then return cached end

  local icon = ICONS[lower]
  if icon then
    STATE.icon_cache[lower] = icon
    return icon
  end

  for i = 1, #ICONS_FUZZY_KEYS do
    local k = ICONS_FUZZY_KEYS[i]
    if lower:find(k, 1, true) then
      local ic = ICONS[k]
      STATE.icon_cache[lower] = ic
      return ic
    end
  end

  STATE.icon_cache[lower] = " "
  return " "
end

config.color_scheme = "iceberg-dark"
config.colors = {
  tab_bar = {
    active_tab         = { bg_color = COLORS.tab_active_bg, fg_color = COLORS.fg },
    inactive_tab       = { bg_color = COLORS.tab_inactive_bg, fg_color = COLORS.tab_inactive_fg },
    inactive_tab_hover = { bg_color = COLORS.hover_bg, fg_color = COLORS.fg },
    new_tab            = { bg_color = COLORS.hover_bg, fg_color = COLORS.fg },
  },
  split = COLORS.fg,
}

-- WezTerm automatically appends built-in fonts after this list:
-- JetBrains Mono, Noto Color Emoji, and Symbols Nerd Font Mono (always last)
config.font = wezterm.font_with_fallback({
  "Geist Mono",
  "JetBrains Mono",
  IS_WINDOWS and "Segoe UI Emoji" or nil,
})
config.font_size = 9.5
config.harfbuzz_features = { "calt=1", "clig=0", "liga=0" }
config.line_height = 1.1

config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_padding = {
  left   = "1cell",
  right  = "0.5cell",
  top    = "0.5cell",
  bottom = "0.25cell",
}
config.window_frame = {
  active_titlebar_bg = COLORS.active_titlebar,
  inactive_titlebar_bg = COLORS.inactive_titlebar,
  font = wezterm.font_with_fallback({
    { family = "Inter",  weight = "Bold" },
    { family = "Roboto", weight = "Bold" }, -- ships with WezTerm
  }),
}

config.adjust_window_size_when_changing_font_size = false

--- @param title string
--- @return string
local function clean_title(title)
  title = title:gsub(".*[\\/]", "")
  title = title:gsub("%.exe$", "")
  if title:find("wsl", 1, true) then return "wsl" end
  return title
end

wezterm.on("format-tab-title", function(tab)
  local title = tab.active_pane.title
  local clean = clean_title(title)

  local icon = get_icon(clean)
  local admin = title:find("Administrator:", 1, true) or title:find("root", 1, true) or title:find("#", 1, true)

  return string.format(" %s%s %d: %s ", admin and "󰒙 " or "", icon, tab.tab_index + 1, clean)
end)

wezterm.on("update-right-status", function(window, _)
  local is_leader = window:leader_is_active()
  if STATE.status_cache.leader == is_leader then return end
  STATE.status_cache.leader = is_leader

  if not is_leader then
    window:set_right_status("")
    return
  end

  window:set_right_status(LEADER_STATUS)
end)

return config
