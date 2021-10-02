local util = require("include/util")

local function GenerateEnergy(self, world)
	local bx, by = self.body:getWorldCenter()
	
	local power = math.floor((1000 - by)/100)
	
	EffectsHandler.SpawnEffect("mult_popup", {bx, by}, {velocity = {0, (-0.55 - math.random()*0.2) * (0.4 + 0.6*(50 / math.max(50, power)))}, text = power})
end

return {
	maxNumberOfVertices = 8,
	imageTexture = "3",
	coords = {{1,0}, {1, 1}, {0, 1}, {-2, 0}},
	minSize = 80,
	maxSize = 100,
	EnergyFunc = GenerateEnergy
}