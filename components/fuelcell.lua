local util = require("include/util")

local wasHitSum = false
local ignoreHitIndexUglyGlobal = false
local function HitTest(fixture, x, y, xn, yn, fraction)
	local component = fixture:getUserData()
	if component and (component.index == ignoreHitIndexUglyGlobal or component.inShop or component.isDead) then
		return 1
	end
	fraction = (1 - fraction)*0.7 + 0.3
	EffectsHandler.SpawnEffect("fireball_explode", {x, y}, {scale = 0.15*fraction})
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

local function CheckAdjacency(self, world)
	local bx, by = self.body:getWorldCenter()
	local physicsWorld = world.GetPhysicsWorld()
	
	local power = 2
	for i = 1, #rayTests do
		local rayPos = util.Add({bx, by}, rayTests[i])
		wasHitSum = 0
		ignoreHitIndexUglyGlobal = self.index
		physicsWorld:rayCast(bx, by - 15, rayPos[1], rayPos[2], HitTest)
		if wasHitSum < 1 then
			power = power + 2*math.max(0, 1 - wasHitSum)
		end
	end
end

return {
	maxNumberOfVertices = 8,
	minSize = 80,
	maxSize = 100,
	foregroundImage = "fuelcell_icon",
	backgroundImage = "nuclear",
	borderImage = "nuclear",
	borderThickness = 40,
	CheckAdjacency = CheckAdjacency,
}
