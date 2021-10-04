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
		wasHitSum = wasHitSum + (component.def.wind_opacity or 0.5)
	else
		wasHitSum = wasHitSum + 1
	end
	return 1
end

local rayTests = {
	{-160, 0},
	{-180, -50},
	{-200, 50},
	{160, 0},
	{180, -50},
	{200, 50},
}
local raySide = {
	-25,
	-25,
	-25,
	25,
	25,
	25,
}

local function ResetAggregators(self, world, AggFunc)
	self.hitByMarketing = 0
	AggFunc("popCost", self.def.popCost)
end

local function GenerateEnergy(self, world, AggFunc)
	local bx, by = self.body:getWorldCenter()
	local physicsWorld = world.GetPhysicsWorld()
	local work = GameHandler.GetWorkEfficiency()

	local heightMult = (1000 - by)/1200 + 1
	
	local power = 60
	for i = 1, #rayTests do
		local rayPos = util.Add({bx + raySide[i], by}, rayTests[i])
		wasHitSum = 0
		ignoreHitIndexUglyGlobal = self.index
		physicsWorld:rayCast(bx, by - 5, rayPos[1], rayPos[2], HitTest)
		if wasHitSum < 1 then
			power = power + 12*math.max(0, 1 - wasHitSum)
		end
	end
	power = (power*0.35 + power*0.65*heightMult)*work
	
	power = util.Round(power, 5)
	local text = power
	if self.hitByMarketing > 0 then
		local marketBonus = math.ceil(power*self.hitByMarketing*work)
		text = text .. " + " .. marketBonus
		power = power + marketBonus
	end
	
	if ComponentHandler.WantEffectsGraphics() then
		EffectsHandler.SpawnEffect("mult_popup", {bx, by}, {velocity = {0, (-0.55 - math.random()*0.2) * (0.4 + 0.6*(50 / math.max(50, power)))}, text = text})
	end
	AggFunc("wind", power)
end

return {
	density = 1 * Global.DENSITY_MULT,
	maxNumberOfVertices = 8,
	minSize = 80,
	maxSize = 100,
	wind_opacity = 0.75,
	GenerateEnergy = GenerateEnergy,
	ResetAggregators = ResetAggregators,
	foregroundImage = "wind_icon",
	backgroundImage = "solar",
	borderImage = "wind",
	borderThickness = 40,
	seaDamage = 0.05 * Global.SEA_DAMAGE_MULT,
	popCost = 1,
}
