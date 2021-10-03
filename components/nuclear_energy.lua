local util = require("include/util")

local function ResetAggregators(self, world)
	self.hitByNuclear = 0
end

local function GenerateEnergy(self, world)
	local bx, by = self.body:getWorldCenter()
	local power = math.floor((self.hitByNuclear or 0)*9)
	
	ComponentHandler.AddEnergy("nuclear", power)
	if power > 0 then
		EffectsHandler.SpawnEffect("mult_popup", {bx, by}, {velocity = {0, (-0.55 - math.random()*0.2) * (0.4 + 0.6*(50 / math.max(50, power)))}, text = power})
	else
		EffectsHandler.SpawnEffect("mult_popup", {bx, by}, {velocity = {0, (-0.55 - math.random()*0.2) * (0.4 + 0.6*(50 / math.max(50, power)))}, text = "No Reactor"})
	end
end

return {
	maxNumberOfVertices = 8,
	minSize = 80,
	maxSize = 100,
	backgroundImage = "nuclear_energy",
	borderImage = "nuclear_energy",
	borderThickness = 40,
	ResetAggregators = ResetAggregators,
	GenerateEnergy = GenerateEnergy,
}
