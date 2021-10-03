local util = require("include/util")

local function ResetAggregators(self, world, AggFunc)
	self.hitByNuclear = 0
	AggFunc("popCost", self.def.popCost)
end

local function GenerateEnergy(self, world, AggFunc)
	local bx, by = self.body:getWorldCenter()
	
	if (self.hitByNuclear or 0) > 0 then
		EffectsHandler.SpawnEffect("mult_popup", {bx, by}, {velocity = {0, (-0.55 - math.random()*0.2) * (0.4 + 0.6)}, text = "Irradiated!!!"})
		return
	end
	local work = GameHandler.GetWorkEfficiency()
	
	EffectsHandler.SpawnEffect("mult_popup", {bx, by}, {velocity = {0, (-0.55 - math.random()*0.2) * (0.4 + 0.6)}, text = "Science"})
	AggFunc("research", self.def.researchPower*work)
end

return {
	maxNumberOfVertices = 8,
	minSize = 80,
	maxSize = 100,
	foregroundImage = "research_icon",
	backgroundImage = "research",
	borderImage = "research",
	borderThickness = 40,
	researchPower = 0.1,
	GenerateEnergy = GenerateEnergy,
	ResetAggregators = ResetAggregators,
	seaDamage = 0.06,
	popCost = 2,
}
