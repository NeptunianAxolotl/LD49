local util = require("include/util")

local function ResetAggregators(self, world)
	self.hitByNuclear = 0
	self.hitByMarketing = 0
end

local function GenerateEnergy(self, world)
	local bx, by = self.body:getWorldCenter()
	local power = math.floor((math.pow(self.hitByNuclear, 0.7) or 0)*12)
	
	if power > 0 then
		local text = power
		if self.hitByMarketing > 0 then
			text = text .. " + " .. math.floor(power*self.hitByMarketing)
			power = power*(1 + self.hitByMarketing)
		end
		EffectsHandler.SpawnEffect("mult_popup", {bx, by}, {velocity = {0, (-0.55 - math.random()*0.2) * (0.4 + 0.6*(50 / math.max(50, power)))}, text = text})
	else
		EffectsHandler.SpawnEffect("mult_popup", {bx, by}, {velocity = {0, (-0.55 - math.random()*0.2) * (0.4 + 0.6*(50 / math.max(50, power)))}, text = "No Fuel"})
	end
	ComponentHandler.AddEnergy("nuclear", power)
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
}
