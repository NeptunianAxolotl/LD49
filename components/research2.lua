local util = require("include/util")

local function ResetAggregators(self, world, AggFunc)
	self.hitByNuclear = 0
	AggFunc("popCost", self.def.popCost)
end

local function GenerateEnergy(self, world, AggFunc)
	local bx, by = self.body:getWorldCenter()
	
	if (self.hitByNuclear or 0) > 0 then
		if ComponentHandler.WantEffectsGraphics() then
			EffectsHandler.SpawnEffect("irradiate", {bx, by}, {scale = self.imageRadius/50})
		end
		return
	end
	local work = GameHandler.GetWorkEfficiency()
	
	if ComponentHandler.WantEffectsGraphics() then
		EffectsHandler.SpawnEffect("research_popup", util.Add({0, Global.INC_OFFSET}, {bx, by}), {velocity = {0, (-0.55 - math.random()*0.2) * (0.4 + 0.6)}, text = self.def.researchPower})
	end
	AggFunc("research", self.def.researchPower*work*Global.TECH_MULT)
end

return {
	density = 1.5 * Global.DENSITY_MULT,
	maxNumberOfVertices = 8,
	minSize = 80,
	maxSize = 100,
	foregroundImage = "research_icon",
	backgroundImage = "research2",
	borderImage = "research2",
	borderThickness = 40,
	researchPower = 25,
	GenerateEnergy = GenerateEnergy,
	ResetAggregators = ResetAggregators,
	seaDamage = 0.1 * Global.SEA_DAMAGE_MULT,
	popCost = 2,
	nuclearDisables = true,
}
