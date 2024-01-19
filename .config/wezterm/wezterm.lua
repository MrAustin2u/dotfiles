local wezterm = require("wezterm")
local events = require("utils.events")

local config = {}

config = wezterm.config_builder()

-- Font
config.font = wezterm.font("MonoLisa")
config.font_size = 15
config.command_palette_font_size = 14
config.line_height = 1.2

-- Colors
config.color_scheme = "tokyonight"

-- Window
-- disable annoying window close confirmation
config.window_close_confirmation = 'NeverPrompt'
config.window_decorations = "RESIZE"
config.window_background_opacity = 1.0

-- Tabs
-- disable tab bar (tabs are handled by tmux)
config.enable_tab_bar = false

-- if enabling this, check https://github.com/stepanzak/dotfiles/blob/main/dot_config/wezterm/wezterm.lua
-- config.disable_default_key_bindings = true
config.keys = {
  -- activate WezTerm's Command Palette
  {
    key = "p",
    mods = 'SUPER|SHIFT',
    action = wezterm.action.ActivateCommandPalette,
  },

  -- toggle opacity and blur
  {
    key = "o",
    mods = 'SUPER|SHIFT',
    action = events.toggle_opacity,
  }
}


return config
