local util = require("include/util")

local function ResetAggregators(self, world, AggFunc)
	self.hitByNuclear = 0
	self.hitByMarketing = 0
	AggFunc("popCost", self.def.popCost)
end

local function GenerateEnergy(self, world, AggFunc)
	local bx, by = self.body:getWorldCenter()
	local work = GameHandler.GetWorkEfficiency()
	local power = math.pow(self.hitByNuclear or 0, 0.7)*110*work
	
	if power > 0 then
		power = util.Round(power, 5)
		local text = power
		if self.hitByMarketing > 0 then
			local marketBonus = math.ceil(power*self.hitByMarketing*work)
			text = text .. " + " .. marketBonus
			power = power + marketBonus
		end
		if ComponentHandler.WantEffectsGraphics() then
			EffectsHandler.SpawnEffect("mult_popup", util.Add({0, Global.INC_OFFSET}, {bx, by}), {velocity = {0, (-0.55 - math.random()*0.2) * (0.4 + 0.6*(50 / math.max(50, power)))}, text = text})
		end
	else
		if ComponentHandler.WantEffectsGraphics() then
			EffectsHandler.SpawnEffect("error_popup", util.Add({0, Global.INC_OFFSET}, {bx, by}), {velocity = {0, (-0.55 - math.random()*0.2) * (0.4 + 0.6*(50 / math.max(50, power)))}, text = "No Fuel"})
		end
	end
	
	if power > 0 and ComponentHandler.WantEffectsGraphics() then
		for i = 1, math.ceil(math.sqrt(power)*0.1) do
			local vel = util.Add({0, -0.4}, util.RandomPointInCircle(0.22))
			EffectsHandler.SpawnEffect("reactor_smoke", {bx - 0.22*self.imageRadius, by - 0.32*self.imageRadius}, {scale = 0.02*(1 + 0.6*math.random())*self.imageRadius, velocity = vel})
			vel = util.Add({0, -0.4}, util.RandomPointInCircle(0.24))
			EffectsHandler.SpawnEffect("reactor_smoke", {bx + 0.24*self.imageRadius, by - 0.44*self.imageRadius}, {scale = 0.02*(1 + 0.6*math.random())*self.imageRadius, velocity = vel})
		end
	end
	
	AggFunc("nuclear", power)
end

return {
	density = 1.6 * Global.DENSITY_MULT,
	maxNumberOfVertices = 8,
	minSize = 80,
	maxSize = 100,
	foregroundImage = "generator_icon",
	backgroundImage = "nuclear",
	borderImage = "nuclear",
	borderThickness = 40,
	ResetAggregators = ResetAggregators,
	GenerateEnergy = GenerateEnergy,
	seaDamage = 0.10 * Global.SEA_DAMAGE_MULT,
	popCost = 3,
}
