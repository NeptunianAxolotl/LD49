function love.conf(t)
	t.window.title = "LD49"
	t.window.width = 1120
	t.window.height = 832
	--t.window.fullscreen = true -- Do not fullscreen since we lack an exit button.
	t.window.resizable = true
	--t.window.icon = "resources/images/hat.png"

	t.modules.joystick = false
	--t.window.fullscreen = true 
	--t.window.fullscreentype = "desktop" 
end

