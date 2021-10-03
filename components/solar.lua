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
		wasHitSum = wasHitSum + (component.def.opacity or 1)
	else
		wasHitSum = wasHitSum + 1
	end
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

local function ResetAggregators(self, world, AggFunc)
	self.hitByMarketing = 0
	AggFunc("popCost", self.def.popCost)
end

local function GenerateEnergy(self, world, AggFunc)
	local bx, by = self.body:getWorldCenter()
	local physicsWorld = world.GetPhysicsWorld()
	local work = GameHandler.GetWorkEfficiency()
	
	local power = 30
	for i = 1, #rayTests do
		local rayPos = util.Add({bx, by}, rayTests[i])
		wasHitSum = 0
		ignoreHitIndexUglyGlobal = self.index
		physicsWorld:rayCast(bx, by - 15, rayPos[1], rayPos[2], HitTest)
		if wasHitSum < 1 then
			power = power + 20*math.max(0, 1 - wasHitSum)
		end
	end

	power = power*work
	power = math.ceil(power)
	local text = power
	if self.hitByMarketing > 0 then
		local marketBonus = math.ceil(power*self.hitByMarketing*work)
		text = text .. " + " .. marketBonus
		power = power + marketBonus
	end
	
	EffectsHandler.SpawnEffect("mult_popup", {bx, by}, {velocity = {0, (-0.55 - math.random()*0.2) * (0.4 + 0.6*(50 / math.max(50, power)))}, text = text})
	AggFunc("solar", power)
end

return {
	maxNumberOfVertices = 8,
	minSize = 80,
	maxSize = 100,
	GenerateEnergy = GenerateEnergy,
	ResetAggregators = ResetAggregators,
	foregroundImage = "solar_icon",
	backgroundImage = "solar",
	borderImage = "solar",
	borderThickness = 40,
	opacity = 0.3,
	seaDamage = 0.04,
	popCost = 1,
}
