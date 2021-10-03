local util = require("include/util")

local wasHitSum = false
local wasHitMultParam = false
local ignoreHitIndexUglyGlobal = false
local function HitTest(fixture, x, y, xn, yn, fraction)
	local component = fixture:getUserData()
	if component and component.index == ignoreHitIndexUglyGlobal then
		return 1
	end
	if not component then
		wasHitSum = wasHitSum + 1
		return 1
	end
	if wasHitMultParam and ComponentHandler.GetComponentByIndex(component.index) then
		wasHitSum = wasHitSum + (ComponentHandler.GetComponentByIndex(component.index).def[wasHitMultParam] or 1)
	else
		wasHitSum = wasHitSum + 1
	end
	return 1
end

local rayTests = {
	{-600, -600},
	{-400, -900},
	{-200, -1000},
	{0, -1000},
	{200, -1000},
	{400, -900},
	{600, -600},
}

local function GenerateEnergy(self, world)
	local bx, by = self.body:getWorldCenter()
	local physicsWorld = world.GetPhysicsWorld()
	
	local power = 2
	for i = 1, #rayTests do
		local rayPos = util.Add({bx, by}, rayTests[i])
		wasHitSum = 0
		wasHitMultParam = "opacity"
		ignoreHitIndexUglyGlobal = self.index
		physicsWorld:rayCast(bx, by - 15, rayPos[1], rayPos[2], HitTest)
		if wasHitSum < 1 then
			power = power + 2*math.max(0, 1 - wasHitSum)
		end
	end
	
	EffectsHandler.SpawnEffect("mult_popup", {bx, by}, {velocity = {0, (-0.55 - math.random()*0.2) * (0.4 + 0.6*(50 / math.max(50, power)))}, text = power})
end

return {
	maxNumberOfVertices = 8,
	minSize = 80,
	maxSize = 100,
	EnergyFunc = GenerateEnergy,
	foregroundImage = "office",
	backgroundImage = "solar",
	borderImage = "solar",
	borderThickness = 40,
	opacity = 0.3,
}
