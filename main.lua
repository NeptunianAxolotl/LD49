
local Font = require("include/font")
Global = require("global")
local World = require("world")
local Resources = require("resourceHandler")

--------------------------------------------------
-- Draw
--------------------------------------------------

function love.draw()
	World.Draw()
end

--------------------------------------------------
-- Input
--------------------------------------------------

function love.mousemoved(x, y, dx, dy, istouch )
end

function love.mousereleased(x, y, button, istouch, presses)
	World.MouseReleased(x, y, button, istouch, presses)
end

function love.keypressed(key, scancode, isRepeat)
	World.KeyPressed(key, scancode, isRepeat)
end

function love.mousepressed(x, y, button, istouch, presses)
	World.MousePressed(x, y, button, istouch, presses)
end

--------------------------------------------------
-- Update
--------------------------------------------------

function love.update(dt)
	local realDt = dt
	if dt > 0.1 then
		dt = 0.1
	end
	World.Update(dt, realDt)
end

local util = require("include/util")
--------------------------------------------------
-- Loading
--------------------------------------------------
function love.load(arg)
	if arg[#arg] == "-debug" then require("mobdebug").start() end
	local major, minor, revision, codename = love.getVersion()
	--print(string.format("Version %d.%d.%d - %s", major, minor, revision, codename))

	love.graphics.setBackgroundColor(6/255, 9/225, 15/255, 1)

	love.keyboard.setKeyRepeat(true)
	math.randomseed(os.clock())
	Resources.LoadResources()
	World.Initialize()
	
	love.window.maximize() -- Do not fullscreen since we lack an exit button.
end
