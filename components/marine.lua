local util = require("include/util")

local function ResetAggregators(self, world, AggFunc)
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
	
	local generated = GameHandler.GetSeaHealMult()*self.def.seaHealPower
	if ComponentHandler.WantEffectsGraphics() and GameHandler.GetRealSeaDamage() > 0 then
		EffectsHandler.SpawnEffect("heal_popup", util.Add({0, Global.INC_OFFSET}, {bx, by}), {velocity = {0, (-0.55 - math.random()*0.2) * (0.4 + 0.6)}, text = "-" .. ("%.2g"):format(generated*100) .. "%"})
	end
	AggFunc("heal", generated)
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
	GenerateEnergy_Post = GenerateEnergy_Post,
	seaHealPower = 1,
	seaDamage = 0.05 * Global.SEA_DAMAGE_MULT,
	nuclearDisables = true,
}
