local util = require("include/util")

local ignoreHitIndexUglyGlobal = false
local alreadyHit = false
local function HitTest(fixture, x, y, xn, yn, fraction)
	local component = fixture:getUserData()
	if component and (component.index == ignoreHitIndexUglyGlobal or component.inShop or component.isDead) then
		return 1
	end
	fraction = (1 - fraction)*0.7 + 0.3
	if ComponentHandler.WantEffectsGraphics() then
		EffectsHandler.SpawnEffect("fireball_explode_purple", {x, y}, {scale = 0.04 + 0.04*fraction})
	end
	if not component then
		return 1
	end
	if alreadyHit[component.index] then
		return 1
	end
	alreadyHit[component.index] = true
	component.hitByNuclear = (component.hitByNuclear or 0) + 1.65*fraction
	return 1
end

local rayTests = {}
for i = 1, 24 do
	rayTests[i] = util.Mult(190, util.RotateVector({0 , 1}, i*math.pi/12))
end

local function CheckAdjacency(self, world, AggFunc)
	local bx, by = self.body:getWorldCenter()
	local physicsWorld = world.GetPhysicsWorld()

	for i = 1, #rayTests do
		local rayPos = util.Add({bx, by}, rayTests[i])
		ignoreHitIndexUglyGlobal = self.index
		alreadyHit = {}
		physicsWorld:rayCast(bx, by - 15, rayPos[1], rayPos[2], HitTest)
	end
	
	AggFunc("popCost", self.def.popCost)
end

return {
	density = 3 * Global.DENSITY_MULT,
	maxNumberOfVertices = 8,
	minSize = 90,
	maxSize = 110,
	foregroundImage = "fuelcell_icon2",
	backgroundImage = "nuclear_energy",
	borderImage = "nuclear_energy",
	borderThickness = 40,
	CheckAdjacency = CheckAdjacency,
	seaDamage = 0.6 * Global.SEA_DAMAGE_MULT,
	popCost = 1,
}
