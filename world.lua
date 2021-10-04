
local SoundHandler = require("soundHandler")
local ModuleTest = require("moduleTest")
MusicHandler = require("musicHandler")
EffectsHandler = require("effectsHandler")

Camera = require("utilities/cameraUtilities")
Delay = require("utilities/delay")

local PhysicsHandler = require("physicsHandler")
local PowerupHandler = require("powerupHandler")
ChatHandler = require("chatHandler")
DeckHandler = require("deckHandler")
ComponentHandler = require("componentHandler")
ShopHandler = require("shopHandler")
GameHandler = require("gameHandler") -- Handles the gamified parts of the game, such as score, progress and interface.

local island = require("objects/island")

local PriorityQueue = require("include/PriorityQueue")

local self = {}
local api = {}

function api.SetMenuState(newState)
	self.menuState = newState
end

function api.ToggleMusic()
	self.musicEnabled = not self.musicEnabled
	if not self.musicEnabled then
		MusicHandler.StopCurrentTrack()
	end
end

function api.GetPaused()
	return self.paused or self.menuState
end

function api.MusicEnabled()
	return self.musicEnabled
end

function api.GetGameOver()
	return self.gameWon or self.gameLost, self.gameWon, self.gameLost, self.overType
end

function api.Restart()
	PhysicsHandler.Destroy()
	api.Initialize()
end

function api.TakeScreenshot()

end

function api.SetGameOver(hasWon, overType)
	if self.gameWon or self.gameLost then
		return
	end
	if hasWon then
		self.gameWon = true
	else
		self.gameLost = true
		self.overType = overType
	end
end

function api.KeyPressed(key, scancode, isRepeat)
	if key == "escape" then
		GameHandler.ToggleMenu()
		--SoundHandler.PlaySound("pause")
	end
	if key == "r" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
		spi.Restart()
	end
	if api.GetPaused() then
		if key == "return" or key == "kpenter" then
			self.paused = false
			--SoundHandler.PlaySound("pause")
		end
		return
	end
end

function api.MousePressed(x, y)
	local uiX, uiY = self.interfaceTransform:inverse():transformPoint(x, y)
	GameHandler.MousePressed(uiX, uiY)
	if api.GetPaused() or api.GetGameOver() then
		return
	end
	x, y = self.cameraTransform:inverse():transformPoint(x, y)
	PowerupHandler.MouseReleased(x, y)
	ShopHandler.MousePressed(x, y)
	ComponentHandler.MousePressed(x, y)
end

function api.MouseReleased(x, y)
	x, y = self.cameraTransform:inverse():transformPoint(x, y)
	PowerupHandler.MouseReleased(x, y)
	ComponentHandler.MouseReleased(x, y)
end

function api.WorldToScreen(pos)
	local x, y = self.cameraTransform:transformPoint(pos[1], pos[2])
	return {x, y}
end

function api.ScreenToWorld(pos)
	local x, y = self.cameraTransform:inverse():transformPoint(pos[1], pos[2])
	return {x, y}
end

function api.ScreenToInterface(pos)
	local x, y = self.interfaceTransform:inverse():transformPoint(pos[1], pos[2])
	return {x, y}
end

function api.GetMousePositionInterface()
	local x, y = love.mouse.getPosition()
	return api.ScreenToInterface({x, y})
end

function api.GetMousePosition()
	local x, y = love.mouse.getPosition()
	return api.ScreenToWorld({x, y})
end


function api.GetPhysicsWorld()
	return PhysicsHandler.GetPhysicsWorld()
end

function api.Update(dt, realDt)
	MusicHandler.Update(realDt)
	SoundHandler.Update(realDt)
	if api.GetPaused() then
		return
	end
	
	Delay.Update(dt)
	
	PhysicsHandler.Update(math.min(0.04, dt))
	ComponentHandler.Update(dt)
	ShopHandler.Update(dt)
	PowerupHandler.Update(dt)
	--ModuleTest.Update(dt)

	ChatHandler.Update(dt)
	EffectsHandler.Update(dt)
	island.Update(dt)
	GameHandler.Update(dt)
	
	local cameraX, cameraY, cameraScale = Camera.UpdateCameraToViewPoints(dt, ComponentHandler.GetViewRestriction(), 550, 0.98, 0.98)
	Camera.UpdateTransform(self.cameraTransform, cameraX, cameraY, cameraScale)
end

function api.Draw()
	love.graphics.replaceTransform(self.cameraTransform)

	local drawQueue = PriorityQueue.new(function(l, r) return l.y < r.y end)

	island.Draw(drawQueue)
	EffectsHandler.Draw(drawQueue)
	ComponentHandler.Draw(drawQueue)
	ShopHandler.Draw(drawQueue)
	PowerupHandler.Draw(drawQueue)
	
	-- Draw world

	--ModuleTest.Draw(dt)
	
	while true do
		local d = drawQueue:pop()
		if not d then break end
		d.f()
	end
	
	local windowX, windowY = love.window.getMode()
	if windowX/windowY > 16/9 then
		self.interfaceTransform:setTransformation(0, 0, 0, windowY/1080, windowY/1080, 0, 0)
	else
		self.interfaceTransform:setTransformation(0, 0, 0, windowX/1920, windowX/1920, 0, 0)
	end
	love.graphics.replaceTransform(self.interfaceTransform)
	
	-- Draw interface
	EffectsHandler.DrawInterface()
	PowerupHandler.DrawInterface()
	ChatHandler.DrawInterface()
	GameHandler.DrawInterface()
	
	love.graphics.replaceTransform(self.emptyTransform)
end

function api.Initialize()
	self = {}
	self.cameraTransform = love.math.newTransform()
	self.interfaceTransform = love.math.newTransform()
	self.emptyTransform = love.math.newTransform()
	self.paused = false
	self.musicEnabled = true
	
	Delay.Initialise()
	EffectsHandler.Initialize()
	SoundHandler.Initialize()
	MusicHandler.Initialize(api)
	ChatHandler.Initialize(api)
	PhysicsHandler.Initialize(api)
	DeckHandler.Initialize(api)
	ComponentHandler.Initialize(api)
	PowerupHandler.Initialize(api)
	ShopHandler.Initialize(api)
	GameHandler.Initialize(api)
	island.Initialize(api)
	
	-- Note that the camera pins only function for these particular second entries.
	Camera.Initialize({
		pinX = {875, 0.5},
		pinY = {900, 1},
		minScale = 1000,
		initPos = {875, 500}
	})
end

return api
