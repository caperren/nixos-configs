-- Import shared configuration
require("hyprland-common")

-- Laptop-specific monitor configuration
-- VRR is explicitly enabled because Hyprland cannot hot-switch
-- variable refresh rate reliably on this display.
hl.monitor({
    output = "eDP-2",
    mode = "2560x1600@165",
    position = "auto",
    scale = 1,
    vrr = 1,
})

-- Startup commands
hl.on("hyprland.start", function()
	for _, cmd in ipairs({
		"brightnessctl -sd platform::kbd_backlight set 1",
        "brightnessctl -s set 30%",
        [[sleep 10 && if test -e /dev/video1; then notify-send "Laptop Webcam Enabled" "Please disable if not being used." --urgency=critical; fi]]
	}) do
		hl.exec_cmd(cmd)
	end
end)
