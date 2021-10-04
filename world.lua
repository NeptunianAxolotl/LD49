
local SoundHandler = require("soundHandler")
MusicHandler = {require("musicHandler"), require("musicHandler2")}
local ModuleTest = require("moduleTest")
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

function self.GetPaused()
	return self.paused
end

function self.MusicEnabled()
	return self.musicEnabled
end

function self.GetGameOver()
	return self.gameWon or self.gameLost, self.gameWon, self.gameLost, self.overType
end

function self.SetGameOver(hasWon, overType)
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

function self.KeyPressed(key, scancode, isRepeat)
	if key == "escape" then
		self.paused = not self.paused
		--SoundHandler.PlaySound("pause")
	end
	if key == "r" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
		self.Initialize()
	end
	if self.GetPaused() then
		if key == "return" or key == "kpenter" then
			self.paused = false
			--SoundHandler.PlaySound("pause")
		end
		return
	end
end

function self.MousePressed(x, y)
	if self.GetPaused() or self.GetGameOver() then
		return
	end
	x, y = self.cameraTransform:inverse():transformPoint(x, y)
	PowerupHandler.MouseReleased(x, y)
	ShopHandler.MousePressed(x, y)
	ComponentHandler.MousePressed(x, y)
end

function self.MouseReleased(x, y)
	x, y = self.cameraTransform:inverse():transformPoint(x, y)
	PowerupHandler.MouseReleased(x, y)
	ComponentHandler.MouseReleased(x, y)
end

function self.WorldToScreen(pos)
	local x, y = self.cameraTransform:transformPoint(pos[1], pos[2])
	return {x, y}
end

function self.ScreenToWorld(pos)
	local x, y = self.cameraTransform:inverse():transformPoint(pos[1], pos[2])
	return {x, y}
end

function self.ScreenToInterface(pos)
	local x, y = self.interfaceTransform:inverse():transformPoint(pos[1], pos[2])
	return {x, y}
end

function self.GetMousePositionInterface()
	local x, y = love.mouse.getPosition()
	return self.ScreenToInterface({x, y})
end

function self.GetMousePosition()
	local x, y = love.mouse.getPosition()
	return self.ScreenToWorld({x, y})
end


function self.GetPhysicsWorld()
	return PhysicsHandler.GetPhysicsWorld()
end

function self.Update(dt)
	if self.GetPaused() then
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
	MusicHandler[1].Update(dt)
	MusicHandler[2].Update(dt)
	SoundHandler.Update(dt)
	island.Update(dt)
	GameHandler.Update(dt)
	
	local cameraX, cameraY, cameraScale = Camera.UpdateCameraToViewPoints(dt, ComponentHandler.GetViewRestriction(), 550, 0.98, 0.98)
	Camera.UpdateTransform(self.cameraTransform, cameraX, cameraY, cameraScale)
end

function self.Draw()
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
	GameHandler.DrawInterface()
	PowerupHandler.DrawInterface()
	ChatHandler.DrawInterface()
	
	love.graphics.replaceTransform(self.emptyTransform)
end

function self.Initialize()
	self.cameraTransform = love.math.newTransform()
	self.interfaceTransform = love.math.newTransform()
	self.emptyTransform = love.math.newTransform()
	self.paused = false
	
	EffectsHandler.Initialize()
	MusicHandler[1].Initialize()
	MusicHandler[2].Initialize()
	SoundHandler.Initialize()
	ChatHandler.Initialize(self)
	PhysicsHandler.Initialize(self)
	DeckHandler.Initialize(self)
	ComponentHandler.Initialize(self)
	PowerupHandler.Initialize(self)
	ShopHandler.Initialize(self)
	GameHandler.Initialize(self)
	island.Initialize(self)

	MusicHandler[1].SwitchTrack("background_music")
	
	-- Note that the camera pins only function for these particular second entries.
	Camera.Initialize({
		pinX = {875, 0.5},
		pinY = {900, 1},
		minScale = 1000,
		initPos = {875, 500}
	})
end

return self