local util = require("include/util")

local wasHitUglyGlobal = false
local ignoreHitIndexUglyGlobal = false
local function HitTest(fixture, x, y, xn, yn, fraction)
	local component = fixture:getUserData()
	if component and component.index == ignoreHitIndexUglyGlobal then
		return 1
	end
	wasHitUglyGlobal = true
	return 1
end

local rayTests = {
	{-600, -1000},
	{-400, -1000},
	{-200, -1000},
	{0, -1000},
	{200, -1000},
	{400, -1000},
	{600, -1000},
}

local function GenerateEnergy(self, world)
	local bx, by = self.body:getWorldCenter()
	local physicsWorld = world.GetPhysicsWorld()
	
	local power = 0
	for i = 1, #rayTests do
		local rayPos = util.Add({bx, by}, rayTests[i])
		wasHitUglyGlobal = false
		ignoreHitIndexUglyGlobal = self.index
		physicsWorld:rayCast(bx, by - 15, rayPos[1], rayPos[2], HitTest)
		if not wasHitUglyGlobal then
			power = power + 2
		end
	end
	
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
