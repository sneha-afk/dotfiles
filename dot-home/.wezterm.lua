-- ~/.wezterm.lua
-- sneha's wezterm configuration

local wezterm = require "wezterm"
local action = wezterm.action

local config = wezterm.config_builder()

--==============================================================================
-- [1] ENV DETECTION
--==============================================================================
local is_windows = wezterm.target_triple:find("windows") ~= nil

--- Check if an executable exists in the system PATH
---@param executable string Name of the executable
---@return boolean True if the executable exists
local function exe_exists(executable)
  local cmd = is_windows and { "where.exe", "/Q", executable } or { "bash", "-c", "command -v " .. executable }
  local success, _, _ = wezterm.run_child_process(cmd)
  return success == true
end

local HAS_PWSH      = is_windows and exe_exists("pwsh")
local HAS_WSL       = is_windows and exe_exists("wsl")

--==============================================================================
-- [2] THEME
--==============================================================================
config.color_scheme = "iceberg-dark"
local bg            = "#161821"
local fg            = "#d2d4de"
local accent        = "#e98989"

--- adjust_brightness color brightness by percentage (-100 to 100)
---@param hex string Hex color code
---@param percent number Percentage adjust_brightnessment (-100 to 100)
---@return string adjust_brightnessed hex color
local function adjust_brightness(hex, percent)
  local r, g, b = hex:match("#?(%x%x)(%x%x)(%x%x)")
  local factor = 1 + (percent / 100)
  local function clamp(val) return math.floor(math.max(0, math.min(255, tonumber(val, 16) * factor))) end
  return string.format("#%02x%02x%02x", clamp(r), clamp(g), clamp(b))
end

--- Check if a color is dark based on relative luminance
---@param hex string Hex color code
---@return boolean True if color is dark
local function is_dark_theme(hex)
  local r, g, b = hex:match("#?(%x%x)(%x%x)(%x%x)")
  if not r then return true end
  local lum = (tonumber(r, 16) * 0.299 + tonumber(g, 16) * 0.587 + tonumber(b, 16) * 0.114) / 255
  return lum < 0.5
end

local is_dark = is_dark_theme(bg)

local PALETTE = {
  bg                = bg,
  fg                = fg,
  accent            = accent,
  active_titlebar   = adjust_brightness(bg, is_dark and 30 or -30),
  inactive_titlebar = adjust_brightness(bg, is_dark and 50 or -50),
  tab_active_bg     = adjust_brightness(bg, is_dark and 75 or 10),
  tab_inactive_bg   = adjust_brightness(bg, is_dark and -30 or 30),
  tab_inactive_fg   = adjust_brightness(fg, is_dark and -15 or 15),
  hover_bg          = adjust_brightness(bg, is_dark and 15 or -15),
}

config.colors = {
  tab_bar = {
    active_tab         = { bg_color = PALETTE.tab_active_bg, fg_color = PALETTE.fg },
    inactive_tab       = { bg_color = PALETTE.tab_inactive_bg, fg_color = PALETTE.tab_inactive_fg },
    inactive_tab_hover = { bg_color = PALETTE.hover_bg, fg_color = PALETTE.fg },
    new_tab            = { bg_color = PALETTE.hover_bg, fg_color = PALETTE.fg },
  },
  split = PALETTE.fg,
}

--==============================================================================
-- [3] ICON HELPERS
--==============================================================================

local ICON_MAP = {
  ["local"]      = " ",
  ["nvim"]       = " ",
  ["git"]        = " ",
  ["ubuntu"]     = " ",
  ["debian"]     = " ",
  ["arch"]       = " ",
  ["fedora"]     = " ",
  ["wsl"]        = " ",
  ["bash"]       = " ",
  ["zsh"]        = " ",
  ["pwsh"]       = " ",
  ["powershell"] = "󰨊 ",
  ["cmd"]        = " ",
  ["wezterm"]    = " ",
  ["ssh"]        = "󰣀 ",
}

local ICON_CACHE = {}

---Bundled with Wezterm: https://www.nerdfonts.com/cheat-sheet
---@param text string Search against for an icon
---@return string Icon for the text
local function get_icon(text)
  if not text or text == "" then return " " end
  if ICON_CACHE[text] then return ICON_CACHE[text] end

  local p = text:lower()
  for key, icon in pairs(ICON_MAP) do
    if p:find(key) then
      ICON_CACHE[text] = icon
      return icon
    end
  end

  ICON_CACHE[text] = " "
  return " "
end

--==============================================================================
-- [4] CORE TERMINAL SETTINGS
--==============================================================================

config.front_end = "WebGpu"
config.max_fps   = 60

if is_windows then
  config.default_prog = { HAS_PWSH and "pwsh.exe" or "powershell.exe", "-NoLogo" }
end

-- WezTerm comes with JetBrains Mono, symbols, and emojis; but added after this list,
-- so keep JetBrains Mono above the emoji set (always put fonts above emojis)
config.font               = wezterm.font_with_fallback({
  "Geist Mono",
  "JetBrains Mono",
  "Symbols Nerd Font Mono",
  "Segoe UI Emoji",
})
config.font_size          = 10
config.harfbuzz_features  = { "calt=1", "clig=0", "liga=0" }

config.initial_cols       = 128
config.initial_rows       = 32
config.scrollback_lines   = 5000

config.window_decorations = "RESIZE"
config.window_padding     = {
  left = "0.75cell",
  right = "0.5cell",
  top = "0.5cell",
  bottom = "0.25cell",
}
config.window_frame       = {
  active_titlebar_bg = PALETTE.active_titlebar,
  inactive_titlebar_bg = PALETTE.inactive_titlebar,
  font = wezterm.font_with_fallback({
    { family = "Inter",  weight = "Medium" },
    { family = "Geist",  weight = "Medium" },
    { family = "Roboto", weight = "Bold" }, -- default
  }),
}

--==============================================================================
-- [5] KEYBINDINGS
--==============================================================================
-- https:/wezterm.org/config/default-keys.html
config.leader             = { key = ",", mods = "CTRL", timeout_milliseconds = 2000 }
config.keys               = {
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

if is_windows and HAS_WSL then
  table.insert(config.keys, { key = "w", mods = "LEADER|ALT", action = action.SpawnTab { DomainName = "WSL:Ubuntu" } })
end

--==============================================================================
-- [6] RENDER EVENTS
--==============================================================================

-- TAB TITLE: Strip path and .exe, add icons and admin indicator
wezterm.on("format-tab-title", function(tab)
  local raw_title = tab.active_pane.title

  local clean_title = raw_title:gsub(".*[\\/]", ""):gsub("%.exe$", "")
  if clean_title:find("wsl") then clean_title = "wsl" end

  local icon = get_icon(clean_title)
  local is_admin = raw_title:find("Administrator:") or raw_title:find("root") or raw_title:find("#")

  return string.format(" %s%s %d: %s ", is_admin and "󰒙 " or "", icon, tab.tab_index + 1, clean_title)
end)

-- STATUS BAR: Show time, domain icon, and leader status
wezterm.on("update-right-status", function(window, pane)
  local is_leader = window:leader_is_active()
  local time = wezterm.strftime("%I:%M %p")
  local domain = pane:get_domain_name():lower()

  window:set_right_status(wezterm.format({
    { Background = { Color = is_leader and PALETTE.accent or PALETTE.bg } },
    { Foreground = { Color = is_leader and PALETTE.bg or PALETTE.fg } },
    { Text = is_leader and "  󱐋 LEADER  " or "" },
    { Background = { Color = PALETTE.bg } },
    { Foreground = { Color = PALETTE.fg } },
    { Text = string.format(" ┊  %s ┊ %s ┊", get_icon(domain), time) },
  }))
end)

config.adjust_window_size_when_changing_font_size = false

return config
