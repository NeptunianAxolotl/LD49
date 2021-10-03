local util = require("include/util")

local wasHitSum = false
local ignoreHitIndexUglyGlobal = false
local function HitTest(fixture, x, y, xn, yn, fraction)
	local component = fixture:getUserData()
	if component and (component.index == ignoreHitIndexUglyGlobal or component.inShop or component.isDead) then
		return 1
	end
	if not component then
		wasHitSum = wasHitSum + 1
		return 1
	end
	if wasHitMultParam then
		wasHitSum = wasHitSum + (component.def.wind_opacity or 0.6)
	else
		wasHitSum = wasHitSum + 1
	end
	return 1
end

local rayTests = {
	{-1000, 0},
	{-1000, -200},
	{-1000, 200},
	{1000, 0},
	{1000, -200},
	{1000, 200},
}

local function GenerateEnergy(self, world)
	local bx, by = self.body:getWorldCenter()
	local physicsWorld = world.GetPhysicsWorld()

	local heightMult = (1000 - by)/1000 + 1
	
	local power = 1
	for i = 1, #rayTests do
		local rayPos = util.Add({bx, by}, rayTests[i])
		wasHitSum = 0
		ignoreHitIndexUglyGlobal = self.index
		physicsWorld:rayCast(bx, by - 5, rayPos[1], rayPos[2], HitTest)
		if wasHitSum < 1 then
			power = power + math.max(0, 1 - wasHitSum)
		end
	end
	power = power*heightMult
	power = math.floor(power*10)/10
	
	ComponentHandler.AddEnergy("solar", power)
	EffectsHandler.SpawnEffect("mult_popup", {bx, by}, {velocity = {0, (-0.55 - math.random()*0.2) * (0.4 + 0.6*(50 / math.max(50, power)))}, text = power})
end

return {
	maxNumberOfVertices = 8,
	minSize = 80,
	maxSize = 100,
	GenerateEnergy = GenerateEnergy,
	backgroundImage = "wind",
	borderImage = "wind",
	borderThickness = 40,
}
