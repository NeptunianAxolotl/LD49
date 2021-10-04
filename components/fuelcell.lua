local util = require("include/util")

local ignoreHitIndexUglyGlobal = false
local function HitTest(fixture, x, y, xn, yn, fraction)
	local component = fixture:getUserData()
	if component and (component.index == ignoreHitIndexUglyGlobal or component.inShop or component.isDead) then
		return 1
	end
	fraction = (1 - fraction)*0.7 + 0.3
	if ComponentHandler.WantEffectsGraphics() then
		EffectsHandler.SpawnEffect("fireball_explode", {x, y}, {scale = 0.2*fraction})
	end
	if not component then
		return 1
	end
	component.hitByNuclear = (component.hitByNuclear or 0) + fraction
	return 1
end

local rayTests = {}
for i = 1, 24 do
	rayTests[i] = util.Mult(120, util.RotateVector({0 , 1}, i*math.pi/12))
end

local function CheckAdjacency(self, world, AggFunc)
	local bx, by = self.body:getWorldCenter()
	local physicsWorld = world.GetPhysicsWorld()

	for i = 1, #rayTests do
		local rayPos = util.Add({bx, by}, rayTests[i])
		ignoreHitIndexUglyGlobal = self.index
		physicsWorld:rayCast(bx, by - 15, rayPos[1], rayPos[2], HitTest)
	end
	
	AggFunc("popCost", self.def.popCost)
end

return {
	density = 1.4 * Global.DENSITY_MULT,
	maxNumberOfVertices = 8,
	minSize = 80,
	maxSize = 100,
	foregroundImage = "fuelcell_icon",
	backgroundImage = "nuclear",
	borderImage = "nuclear",
	borderThickness = 40,
	CheckAdjacency = CheckAdjacency,
	seaDamage = 0.15,
	popCost = 1,
}
