
local SoundHandler = require("soundHandler")
local MusicHandler = require("musicHandler")
local ModuleTest = require("moduleTest")
EffectsHandler = require("effectsHandler")

local Camera = require("utilities/cameraUtilities")

local PhysicsHandler = require("physicsHandler")
local ComponentHandler = require("componentHandler")
local PowerupHandler = require("powerupHandler")
ShopHandler = require("shopHandler")

local island = require("objects/island")

local PriorityQueue = require("include/PriorityQueue")

local self = {}

function self.MousePressed(x, y)
	x, y = self.cameraTransform:inverse():transformPoint(x, y)
	PowerupHandler.MouseReleased(x, y)
	ShopHandler.MousePressed(x, y)
	ComponentHandler.MousePressed(x, y)
end

function self.GetMousePosition()
	local x, y = love.mouse.getPosition()
	x, y = self.cameraTransform:inverse():transformPoint(x, y)
	return {x, y}
end

function self.MouseReleased(x, y)
	x, y = self.cameraTransform:inverse():transformPoint(x, y)
	PowerupHandler.MouseReleased(x, y)
	ComponentHandler.MouseReleased(x, y)
end

function self.KeyPressed(key, scancode, isRepeat)
end

function self.GetPhysicsWorld()
	return PhysicsHandler.GetPhysicsWorld()
end

function self.Update(dt)
	PhysicsHandler.Update(math.min(0.04, dt))
	ComponentHandler.Update(dt)
	ShopHandler.Update(dt)
	PowerupHandler.Update(dt)
	--ModuleTest.Update(dt)

	EffectsHandler.Update(dt)
	MusicHandler.Update(dt)
	SoundHandler.Update(dt)
	
	local cameraX, cameraY, cameraScale = Camera.UpdateCameraToViewPoints(dt, ComponentHandler.GetViewRestriction(), 500, 0.98, 0.98)
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
	self.interfaceTransform:setTransformation(0, 0, 0, windowX/1920, windowX/1920, 0, 0)
	love.graphics.replaceTransform(self.interfaceTransform)
	
	-- Draw interface
	EffectsHandler.DrawInterface()
	
	love.graphics.replaceTransform(self.emptyTransform)
end

function self.Initialize()
	self.cameraTransform = love.math.newTransform()
	self.interfaceTransform = love.math.newTransform()
	self.emptyTransform = love.math.newTransform()
	
	EffectsHandler.Initialize()
	MusicHandler.Initialize()
	SoundHandler.Initialize()
	PhysicsHandler.Initialize(self)
	ComponentHandler.Initialize(self)
	PowerupHandler.Initialize(self)
	ShopHandler.Initialize(self)
	island.Initialize(self)
	
	-- Note that the camera pins only function for these particular second entries.
	Camera.Initialize({
		pinX = {980, 0.5},
		pinY = {900, 1},
		minScaleX = 1000/1600,
		minScaleY = 1000,
		initPos = {980, 500}
	})
end

return self