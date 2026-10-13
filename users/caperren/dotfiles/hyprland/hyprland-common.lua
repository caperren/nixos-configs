-- Hyprland 0.55.4 - native scrolling layout
-- Monitor fallback; kanshi manages known configurations.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

local terminal = "kitty"
local fileManager = "kitty -e yazi"
local menu = "j4-dmenu-desktop --dmenu='bemenu --ignorecase --line-height 22 --hf \"#10AC25\" --ff \"#10AC25\" --tf \"#10AC25\"' --term='kitty'"
local mod = "SUPER"

hl.env("XCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

hl.config({
	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",
		follow_mouse = 0,
		sensitivity = 0,
		numlock_by_default = true,
		touchpad = {
			natural_scroll = false
		},
	},
	general = {
		gaps_in = 5,
		gaps_out = 5,
		border_size = 2,
		col = {
			active_border = "rgba(0D8A1EFF)",
			inactive_border = "rgba(595959aa)"
		},
		layout = "scrolling",
		allow_tearing = false,
	},
	decoration = {
		rounding = 10,
		blur = {
			enabled = true,
			size = 3,
			passes = 1
		},
		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = "rgba(1a1a1aee)"
		},
	},
	animations = {
		enabled = true
	},
	binds = {
		movefocus_cycles_fullscreen = true
	},
	scrolling = {
		column_width = 0.5,
		fullscreen_on_one_column = true,
		focus_fit_method = 1,
		follow_focus = true,
		follow_min_visible = 0.4,
		explicit_column_widths = "0.25, 0.333, 0.5, 0.667, 0.75, 1.0",
		wrap_focus = false,
		wrap_swapcol = false,
		direction = "right",
	},
	misc = {
		force_default_wallpaper = 1
	},
})

hl.curve("windowBezier", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.animation({ leaf = "windows", enabled = true, speed = 7, bezier = "windowBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 7, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "default" })

-- Pan horizontally across the scrolling tape with three fingers.
hl.gesture({ fingers = 3, direction = "horizontal", action = "scroll_move" })

-- Applications and session
hl.bind(mod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + SHIFT + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mod .. " + SHIFT + Q", hl.dsp.window.close())
-- Safer than the original SUPER+C and SUPER+M shortcuts.
hl.bind(mod .. " + SHIFT + M", hl.dsp.exit())
hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))

-- Focus navigation
for _, direction in ipairs({ "left", "right", "up", "down" }) do
	hl.bind(mod .. " + " .. direction, hl.dsp.focus({ direction = direction }))
end

-- Swap horizontal columns; move individual windows vertically.
hl.bind(mod .. " + SHIFT + left", hl.dsp.layout("swapcol l"))
hl.bind(mod .. " + SHIFT + right", hl.dsp.layout("swapcol r"))
hl.bind(mod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down" }))

-- Stack windows into existing columns, or split them back out.
hl.bind(mod .. " + bracketleft", hl.dsp.layout("consume_or_expel prev"))
hl.bind(mod .. " + bracketright", hl.dsp.layout("consume_or_expel next"))
hl.bind(mod .. " + comma", hl.dsp.layout("consume"))
hl.bind(mod .. " + period", hl.dsp.layout("expel"))

-- Width adjustment and presets
hl.bind(mod .. " + minus", hl.dsp.layout("colresize -0.05"))
hl.bind(mod .. " + equal", hl.dsp.layout("colresize +0.05"))
hl.bind(mod .. " + SHIFT + R", hl.dsp.layout("colresize +conf"))
hl.bind(mod .. " + CTRL + R", hl.dsp.layout("colresize -conf"))
hl.bind(mod .. " + CTRL + BackSpace", hl.dsp.layout("colresize 0.5"))

-- Fit rather than auto-center; manual centerinFFg remains available.
hl.bind(mod .. " + C", hl.dsp.layout("fit active"))
hl.bind(mod .. " + CTRL + F", hl.dsp.layout("fit visible"))
hl.bind(mod .. " + CTRL + SHIFT + F", hl.dsp.layout("fit all"))
hl.bind(mod .. " + ALT + left", hl.dsp.layout("move -col"))
hl.bind(mod .. " + ALT + right", hl.dsp.layout("move +col"))

-- Workspaces 1-10, with 0 meaning 10.
for i = 1, 10 do
	local key = tostring(i % 10)
	hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Audio and media; locked keys work on the lock screen.
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 2%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 2%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 1%-"), { repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s +1%"), { repeating = true })

-- Screenshot controls (unchanged)
local shot = "~/.config/hypr/scripts/screenshot.sh "
for _, entry in ipairs({
	{ "PRINT", "rc" }, { "SUPER + PRINT", "rf" }, { "CTRL + PRINT", "ri" },
	{ "SHIFT + PRINT", "sc" }, { "SUPER + SHIFT + PRINT", "sf" },
	{ "CTRL + SHIFT + PRINT", "si" }, { "ALT + PRINT", "p" },
}) do
	hl.bind(entry[1], hl.dsp.exec_cmd(shot .. entry[2]))
end

-- Suppress maximize requests to avoid unexpected column changes.
hl.window_rule({ name = "suppress-maximize", match = { class = ".*" }, suppress_event = "maximize" })
-- Avoid JetBrains empty/utility popups stealing initial focus.
hl.window_rule({
	name = "jetbrains-popup-focus",
	match = { class = "^jetbrains-.*$", float = true, title = "^($|\\s|win[0-9]+$)" },
	no_initial_focus = false,
})
-- Application-specific starting widths. Match case-sensitive Wayland classes.
hl.window_rule({ name = "kitty-width", match = { class = "^kitty$" }, scrolling_width = 0.333 })
hl.window_rule({ name = "firefox-width", match = { class = "^firefox$" }, scrolling_width = 1.0 })
hl.window_rule({ name = "jetbrains-width", match = { class = "^jetbrains-.*$" }, scrolling_width = 1.0 })
hl.window_rule({ name = "telegram-width", match = { class = "^(org.telegram.desktop|TelegramDesktop)$" }, scrolling_width = 0.25 })
hl.window_rule({ name = "signal-width", match = { class = "^signal$" }, scrolling_width = 0.25 })

-- Run once when Hyprland starts (not on config reload).
hl.on("hyprland.start", function()
	for _, cmd in ipairs({
		"kanshi",
		"ydotoold",
		"hypridle",
		"hyprpaper",
		"wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 10%",
		"waybar",
		"sleep 5 && nm-applet",
		"sleep 5 && blueman-applet",
		"sleep 5 && streamdeck -n",
		"sleep 5 && solaar --window=hide",
		"sleep 5 && systemctl --user start syncthingtray.service",
		"sleep 5 && Telegram -startintray",
		"sleep 5 && signal-desktop",
		"sleep 10 && itch",
		"sleep 15 && hyprctl dispatch closewindow 'title:itch'",
	}) do
		hl.exec_cmd(cmd)
	end
end)
