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

-- Laptop-specific startup commands
hl.on("hyprland.start", function()
    -- Initialize keyboard backlight
    hl.exec_cmd("brightnessctl -sd platform::kbd_backlight set 1")

    -- Set screen brightness to 30%
    hl.exec_cmd("brightnessctl -s set 30%")

    -- Notify if the laptop webcam is enabled/present
    hl.exec_cmd(
        [[sleep 10 && if test -e /dev/video1; then notify-send "Laptop Webcam Enabled" "Please disable if not being used." --urgency=critical; fi]]
    )
end)
