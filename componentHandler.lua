
local IterableMap = require("include/IterableMap")
local util = require("include/util")

local EffectDefs = util.LoadDefDirectory("components")
local NewComponent = require("objects/component")

local self = {}
local api = {}

function api.SpawnComponent(name, pos, data)
	data = data or {}
	data.def = EffectDefs[name]
	data.pos = pos
	IterableMap.Add(self.components, NewComponent(data, self.world.GetPhysicsWorld()))
end

function api.MousePressed(x, y)
	local component = IterableMap.GetFirstSatisfies(self.components, "ClickTest", x, y)
	if component then
		component.SetMouseAnchor(x, y)
	end
end

function api.MouseReleased(x, y)
	IterableMap.ApplySelf(self.components, "SetMouseAnchor")
end

function api.Update(dt)
	IterableMap.ApplySelf(self.components, "Update", dt)
end

function api.Draw(drawQueue)
	IterableMap.ApplySelf(self.components, "Draw", drawQueue)
end

function api.Initialize(world)
	self = {
		components = IterableMap.New(),
		animationTimer = 0,
		world = world,
	}
	
	-- Testing
	data = {
		initVelocity = {80, 80}
	}
	api.SpawnComponent("generator", {200, 200}, data)
	data = {
		initVelocity = {-80, 80}
	}
	api.SpawnComponent("generator", {400, 200}, data)
	data = {
		initVelocity = {-80, 0}
	}
	api.SpawnComponent("generator", {600, 200}, data)
end

return api
