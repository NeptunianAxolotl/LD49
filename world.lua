
local SoundHandler = require("soundHandler")
local MusicHandler = require("musicHandler")
local ModuleTest = require("moduleTest")
EffectsHandler = require("effectsHandler")

local PhysicsHandler = require("physicsHandler")
local ComponentHandler = require("componentHandler")
local PowerupHandler = require("powerupHandler")
ShopHandler = require("shopHandler")

local island = require("objects/island")

local PriorityQueue = require("include/PriorityQueue")

local self = {}

function self.MousePressed(x, y)
	ComponentHandler.MousePressed(x, y)
	PowerupHandler.MouseReleased(x, y)
	ShopHandler.MousePressed(x, y)
end

function self.MouseReleased(x, y)
	ComponentHandler.MouseReleased(x, y)
	PowerupHandler.MouseReleased(x, y)
end

function self.KeyPressed(key, scancode, isRepeat)
end

function self.GetPhysicsWorld()
	return PhysicsHandler.GetPhysicsWorld()
end

function self.Update(dt)
	--local playerPos, playerVelocity, playerSpeed = Player.GetPhysics()
	--local cameraX, cameraY, cameraScale = Camera.UpdateCamera(dt, playerPos, playerVelocity, playerSpeed, Player.IsDead() and 0.96 or 0.85)
	local windowX, windowY = love.window.getMode()
	local cameraX, cameraY, cameraScale = 0, 0, 1
	--self.cameraTransform:setTransformation(windowX/2, 160 + (1 - cameraScale)*60, 0, cameraScale*windowY/1080, cameraScale*windowY/1080, cameraX, cameraY)
	
	PhysicsHandler.Update(math.min(0.04, dt))
	ComponentHandler.Update(dt)
	ShopHandler.Update(dt)
	PowerupHandler.Update(dt)
	--ModuleTest.Update(dt)

	EffectsHandler.Update(dt)
	MusicHandler.Update(dt)
	SoundHandler.Update(dt)
	
	--love.graphics.replaceTransform(self.cameraTransform)

end

function self.Draw()
	love.graphics.replaceTransform(self.cameraTransform)

	local drawQueue = PriorityQueue.new(function(l, r) return l.y < r.y end)

	island.Draw(drawQueue)
	EffectsHandler.Draw(drawQueue)
	ComponentHandler.Draw(drawQueue)
	ShopHandler.Draw(drawQueue)
	
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
end

return self