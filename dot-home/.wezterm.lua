-- ~/.wezterm.lua

local wezterm = require "wezterm"
local action = wezterm.action

local config = wezterm.config_builder()

--==============================================================================
-- [1] GLOBAL STATE CACHE
--==============================================================================
local STATE = {
  env = {},
  colors = {},
  icon_cache = {},
  status_cache = { domain = "", leader = false },
}

-- Refresh expensive computations only on config reload or window launch
local function refresh_state()
  local is_windows = wezterm.target_triple:find("windows") ~= nil
  local is_linux = wezterm.target_triple:find("linux") ~= nil
  local is_mac = wezterm.target_triple:find("darwin") ~= nil

  local function check_exe(executable)
    local cmd = is_windows and { "where.exe", "/Q", executable } or { "bash", "-c", "command -v " .. executable }
    local success, _, _ = wezterm.run_child_process(cmd)
    return success == true
  end

  local default_shell = nil
  if is_windows then
    local has_pwsh = check_exe("pwsh")
    default_shell = { has_pwsh and "pwsh.exe" or "powershell.exe", "-NoLogo" }
  elseif is_linux then
    default_shell = { "bash", "-l" }
  elseif is_mac then
    local has_zsh = check_exe("zsh")
    default_shell = has_zsh and { "zsh", "-l" } or { "bash", "-l" }
  end

  STATE.env = {
    is_windows = is_windows,
    is_linux = is_linux,
    is_mac = is_mac,
    has_wsl = is_windows and check_exe("wsl"),
    default_shell = default_shell,
  }

  local base_bg = "#161821"
  local base_fg = "#d2d4de"
  local base_accent = "#e98989"

  local function adjust(hex, percent)
    local r, g, b = hex:match("#?(%x%x)(%x%x)(%x%x)")
    local factor = 1 + (percent / 100)
    local function clamp(val)
      return math.floor(math.max(0, math.min(255, tonumber(val, 16) * factor)))
    end
    return string.format("#%02x%02x%02x", clamp(r), clamp(g), clamp(b))
  end

  local function is_dark(hex)
    local r, g, b = hex:match("#?(%x%x)(%x%x)(%x%x)")
    if not r then return true end
    local lum = (tonumber(r, 16) * 0.299 + tonumber(g, 16) * 0.587 + tonumber(b, 16) * 0.114) / 255
    return lum < 0.5
  end

  local dark = is_dark(base_bg)

  STATE.colors = {
    bg = base_bg,
    fg = base_fg,
    accent = base_accent,
    active_titlebar = adjust(base_bg, dark and 30 or -30),
    inactive_titlebar = adjust(base_bg, dark and 50 or -50),
    tab_active_bg = adjust(base_bg, dark and 75 or 10),
    tab_inactive_bg = adjust(base_bg, dark and -30 or 30),
    tab_inactive_fg = adjust(base_fg, dark and -15 or 15),
    hover_bg = adjust(base_bg, dark and 15 or -15),
  }
end

-- Initialize on startup
refresh_state()

-- Refresh only on config reload
wezterm.on("window-config-reloaded", function()
  refresh_state()
end)

--==============================================================================
-- [2] CORE TERMINAL SETTINGS
--==============================================================================
config.front_end = "WebGpu"
config.max_fps = 60

if STATE.env.default_shell then config.default_prog = STATE.env.default_shell end

config.initial_cols = 128
config.initial_rows = 32

--==============================================================================
-- [3] KEYBINDINGS
--==============================================================================
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

-- WSL launcher (conditional)
if STATE.env.has_wsl then
  table.insert(config.keys, {
    key = "w",
    mods = "LEADER|ALT",
    action = action.SpawnTab { DomainName = "WSL:Ubuntu" },
  })
end

--==============================================================================
-- [4] APPEARANCE
--==============================================================================
local ICONS = {
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

local function get_icon(text)
  if not text or text == "" then return " " end
  if STATE.icon_cache[text] then return STATE.icon_cache[text] end

  local lower = text:lower()

  -- Fast path: exact match
  if ICONS[lower] then
    STATE.icon_cache[text] = ICONS[lower]
    return ICONS[lower]
  end

  -- Slow path: substring match
  for key, icon in pairs(ICONS) do
    if lower:find(key, 1, true) then
      STATE.icon_cache[text] = icon
      return icon
    end
  end

  STATE.icon_cache[text] = " "
  return " "
end

config.color_scheme = "iceberg-dark"
config.colors = {
  tab_bar = {
    active_tab = { bg_color = STATE.colors.tab_active_bg, fg_color = STATE.colors.fg },
    inactive_tab = { bg_color = STATE.colors.tab_inactive_bg, fg_color = STATE.colors.tab_inactive_fg },
    inactive_tab_hover = { bg_color = STATE.colors.hover_bg, fg_color = STATE.colors.fg },
    new_tab = { bg_color = STATE.colors.hover_bg, fg_color = STATE.colors.fg },
  },
  split = STATE.colors.fg,
}

-- WezTerm comes with JetBrains Mono, symbols, and emojis; but added after this list,
-- so keep JetBrains Mono above the emoji set (always put fonts above emojis)
config.font = wezterm.font_with_fallback({
  "Geist Mono",
  "JetBrains Mono",
  "Symbols Nerd Font Mono",
  "Segoe UI Emoji",
})
config.font_size = 10
config.harfbuzz_features = { "calt=1", "clig=0", "liga=0" }

config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_padding = {
  left = "0.75cell",
  right = "0.5cell",
  top = "0.5cell",
  bottom = "0.25cell",
}
config.window_frame = {
  active_titlebar_bg = STATE.colors.active_titlebar,
  inactive_titlebar_bg = STATE.colors.inactive_titlebar,
  font = wezterm.font_with_fallback({
    { family = "Inter",  weight = "Bold" },
    { family = "Roboto", weight = "Bold" }, -- ships with WezTerm
  }),
}

--==============================================================================
-- [5] APPEARANCE - UI CALLBACKS
--==============================================================================

config.adjust_window_size_when_changing_font_size = false

wezterm.on("format-tab-title", function(tab)
  local title = tab.active_pane.title
  local clean = title:gsub(".*[\\/]", ""):gsub("%.exe$", "")

  if clean:find("wsl") then clean = "wsl" end

  local icon = get_icon(clean)
  local admin = title:find("Administrator:") or title:find("root") or title:find("#")

  return string.format(" %s%s %d: %s ", admin and "󰒙 " or "", icon, tab.tab_index + 1, clean)
end)

wezterm.on("update-right-status", function(window, pane)
  local is_leader = window:leader_is_active()
  local domain = pane:get_domain_name():lower()

  -- Skip redraw if nothing changed
  if STATE.status_cache.leader == is_leader and STATE.status_cache.domain == domain then
    return
  end

  STATE.status_cache.leader = is_leader
  STATE.status_cache.domain = domain

  window:set_right_status(wezterm.format({
    { Background = { Color = is_leader and STATE.colors.accent or STATE.colors.bg } },
    { Foreground = { Color = is_leader and STATE.colors.bg or STATE.colors.fg } },
    { Text = is_leader and "  󱐋 LEADER  " or "" },
    { Background = { Color = STATE.colors.bg } },
    { Foreground = { Color = STATE.colors.fg } },
    { Text = string.format(" ┊  %s ┊ ", get_icon(domain)) },
  }))
end)

return config
