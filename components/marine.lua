local util = require("include/util")

local function ResetAggregators(self, world, AggFunc)
	self.hitByNuclear = 0
	AggFunc("popCost", self.def.popCost)
end

local function GenerateEnergy(self, world, AggFunc)
	local bx, by = self.body:getWorldCenter()
	
	print(self.hitByNuclear, self.hitByNuclear or 0 > 0)
	if (self.hitByNuclear or 0) > 0 then
		EffectsHandler.SpawnEffect("mult_popup", {bx, by}, {velocity = {0, (-0.55 - math.random()*0.2) * (0.4 + 0.6)}, text = "Irradiated!!!"})
		return
	end
	local work = GameHandler.GetWorkEfficiency()
	
	EffectsHandler.SpawnEffect("mult_popup", {bx, by}, {velocity = {0, (-0.55 - math.random()*0.2) * (0.4 + 0.6)}, text = "Conservation"})
	AggFunc("heal", self.def.seaHeal*work)
end

return {
	density = 1.2 * Global.DENSITY_MULT,
	maxNumberOfVertices = 8,
	minSize = 80,
	maxSize = 100,
	foregroundImage = "marine_icon",
	backgroundImage = "marine",
	borderImage = "marine",
	borderThickness = 40,
	ResetAggregators = ResetAggregators,
	GenerateEnergy = GenerateEnergy,
	seaHeal = 1,
	seaDamage = 0.03,
	popCost = 2,
}
