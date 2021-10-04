local util = require("include/util")

local function ResetAggregators(self, world)
	self.hitByNuclear = 0
end

local function GenerateEnergy_Post(self, world, AggFunc)
	local bx, by = self.body:getWorldCenter()
	if (self.hitByNuclear or 0) > 0 then
		if ComponentHandler.WantEffectsGraphics() then
			EffectsHandler.SpawnEffect("irradiate", {bx, by}, {scale = self.imageRadius/50})
		end
		return
	end
	
	local generated = util.RoundDown(ComponentHandler.GetEnergy()*self.def.marketingValue, 2)
	if ComponentHandler.WantEffectsGraphics() then
		EffectsHandler.SpawnEffect("mult_popup", {bx, by}, {velocity = {0, (-0.55 - math.random()*0.2) * (0.4 + 0.6)}, text = generated})
	end
	AggFunc("officeMult", self.def.marketingValue)
	AggFunc("officeEnergy", generated)
end

return {
	density = 1.2 * Global.DENSITY_MULT,
	maxNumberOfVertices = 8,
	minSize = 80,
	maxSize = 100,
	foregroundImage = "office_icon",
	backgroundImage = "office",
	borderImage = "office",
	borderThickness = 40,
	ResetAggregators = ResetAggregators,
	GenerateEnergy_Post = GenerateEnergy_Post,
	seaDamage = 0.05,
	marketingValue = 0.05,
	nuclearDisables = true,
}
