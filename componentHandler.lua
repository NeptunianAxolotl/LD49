
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

function api.GetComponentAt(x, y, noShop)
	return IterableMap.GetFirstSatisfies(self.components, "ClickTest", x, y, noShop)
end

function api.GetComponentByIndex(index)
	return IterableMap.Get(self.components, index)
end

function api.MousePressed(x, y)
	local component = IterableMap.GetFirstSatisfies(self.components, "ClickTest", x, y, not ShopHandler.ShopSelectAllowed())
	if component then
		component.SetMouseAnchor(x, y)
	end
end

function api.MouseReleased(x, y)
	IterableMap.ApplySelf(self.components, "SetMouseAnchor")
end

function api.AddEnergy(eType, value)
	self.energyByType[eType] = (self.energyByType[eType] or 0) + value
end

function api.GetEnergy(eType)
	if eType then
		return ((self.energyByType and self.energyByType[eType]) or 0)
	end
	return api.GetEnergy("solar") + api.GetEnergy("wind") + api.GetEnergy("nuclear") + api.GetEnergy("officeEnergy")
end

function api.GetResearchRate()
	return api.GetEnergy("research")
end

function api.GetOfficeMult()
	return api.GetEnergy("officeMult")
end

function api.GetViewRestriction()
	local pointsToView = {}
	IterableMap.ApplySelf(self.components, "AddToView", pointsToView)
	return pointsToView
end

function api.WantEffectsGraphics()
	return self.showGraphics
end

function api.RecalcEffects(showGraphics)
	self.showGraphics = showGraphics
	self.energyByType = {}
	IterableMap.ApplySelf(self.components, "ResetAggregators", api.AddEnergy)
	IterableMap.ApplySelf(self.components, "CheckAdjacency", api.AddEnergy)
	IterableMap.ApplySelf(self.components, "CheckAdjacency_Post", api.AddEnergy)
	IterableMap.ApplySelf(self.components, "GenerateEnergy", api.AddEnergy)
	IterableMap.ApplySelf(self.components, "GenerateEnergy_Post", api.AddEnergy)
	GameHandler.UpdateRates(api.GetResearchRate(), api.GetEnergy("adminMult"))
end

function api.Update(dt)
	IterableMap.ApplySelf(self.components, "Update", dt)
	
	self.energyTime = self.energyTime + dt
	if self.energyTime > Global.ENERGY_TIME_PERIOD then
		self.energyTime = 0
		api.RecalcEffects(true)
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
	self.energyByType = {}
	
	self.componentDefList = {}
	for key,_ in pairs(ComponentDefs) do
		self.componentDefList[#self.componentDefList + 1] = key
	end
end

return api
