
local IterableMap = require("include/IterableMap")
local util = require("include/util")

local ComponentDefs = util.LoadDefDirectory("components")
local NewComponent = require("objects/component")

local self = {}
local api = {}

function api.SpawnComponent(name, pos, data)
	data = data or {}
	data.def = ComponentDefs[name]
	data.pos = pos
	local component = NewComponent(data, self.world)
	IterableMap.Add(self.components, component)
	return component
end

function api.GetComponentDefList(component)
	return self.componentDefList
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

function api.AddEnergy(value)
	self.totalEnergy = self.totalEnergy + value
end

function api.Update(dt)
	IterableMap.ApplySelf(self.components, "Update", dt)
	
	self.energyTime = self.energyTime + dt
	print(self.energyTime)
	if self.energyTime > Global.ENERGY_TIME_PERIOD then
		self.energyTime = 0
		self.totalEnergy = 0
		IterableMap.ApplySelf(self.components, "GenerateEnergy", api.AddEnergy)
	end
end

function api.Draw(drawQueue)
	IterableMap.ApplySelf(self.components, "Draw", drawQueue)
end

function api.Remove(component)
	if component and component.index then
		component.Destroy()
		IterableMap.Remove(self.components, component.index)
	end
end

function api.Initialize(world)
	self = {
		components = IterableMap.New(),
		animationTimer = 0,
		world = world,
	}
	
	self.energyTime = 0
	self.componentDefList = {}
	for key,_ in pairs(ComponentDefs) do
		self.componentDefList[#self.componentDefList + 1] = key
	end
	
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
