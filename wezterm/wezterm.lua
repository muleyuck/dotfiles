require("format")
require("status")
-- require 'event'

local wezterm = require("wezterm")

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- update check (1 day)
config.check_for_updates = true
config.check_for_updates_interval_seconds = 86400

-- カラースキーム
config.color_scheme = "nordfox"
config.window_background_opacity = 0.85
config.macos_window_background_blur = 30

-- フォント
config.font = wezterm.font_with_fallback({
	{ family = "HackGen Console NF" },
	{ family = "Hack Nerd Font" },
	{ family = "SauceCodePro Nerd Font Mono" },
})
config.font_size = 13.0
config.window_frame = {
	font = wezterm.font({ family = "Roboto", weight = "Bold" }),
	font_size = 11.0,
}

-- -- 最初からフルスクリーンで起動
-- local mux = wezterm.mux
-- wezterm.on("gui-startup", function(cmd)
-- 	local tab, pane, window = mux.spawn_window(cmd or {})
-- 	window:gui_window():toggle_fullscreen()
-- end)

-- デフォルトのkeybindを無効化
config.disable_default_key_bindings = true
-- `keybinds.lua`を読み込み
local keybind = require("keybinds")
-- keybind設定
config.keys = keybind.keys
config.key_tables = keybind.key_tables
-- Leaderキーの設定
config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 2000 }
-- Optionキーの有効化
config.send_composed_key_when_left_alt_is_pressed = true

-- status
config.status_update_interval = 500

-- -- window decorations
-- config.window_decorations = "RESIZE"

-- mouse binds
config.mouse_bindings = require("mousebinds").mouse_bindings

return config
