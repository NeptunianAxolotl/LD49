local util = require("include/util")

local function ResetAggregators(self, world, AggFunc)
	self.hitByNuclear = 0
	self.hitByMarketing = 0
	AggFunc("popCost", self.def.popCost)
end

local function GenerateEnergy(self, world, AggFunc)
	local bx, by = self.body:getWorldCenter()
	local work = GameHandler.GetWorkEfficiency()
	local power = math.pow(self.hitByNuclear or 0, 0.7)*120*work
	
	if power > 0 then
		power = math.ceil(power)
		local text = power
		if self.hitByMarketing > 0 then
			local marketBonus = math.ceil(power*self.hitByMarketing*work)
			text = text .. " + " .. marketBonus
			power = power + marketBonus
		end
		EffectsHandler.SpawnEffect("mult_popup", {bx, by}, {velocity = {0, (-0.55 - math.random()*0.2) * (0.4 + 0.6*(50 / math.max(50, power)))}, text = text})
	else
		power = math.ceil(power)
		EffectsHandler.SpawnEffect("mult_popup", {bx, by}, {velocity = {0, (-0.55 - math.random()*0.2) * (0.4 + 0.6*(50 / math.max(50, power)))}, text = "No Fuel"})
	end
	AggFunc("nuclear", power)
end

return {
	maxNumberOfVertices = 8,
	minSize = 80,
	maxSize = 100,
	foregroundImage = "generator_icon",
	backgroundImage = "nuclear",
	borderImage = "nuclear",
	borderThickness = 40,
	ResetAggregators = ResetAggregators,
	GenerateEnergy = GenerateEnergy,
	seaDamage = 0.07,
	popCost = 3,
}
