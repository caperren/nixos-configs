-- Import shared configuration
require("hyprland-common")

-- Startup commands
hl.on("hyprland.start", function()
	for _, cmd in ipairs({
		"sleep 10 && steam -silent",
	}) do
		hl.exec_cmd(cmd)
	end
end)
