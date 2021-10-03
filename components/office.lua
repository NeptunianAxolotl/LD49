local util = require("include/util")

local marketingValueUglyGlobal = false
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
	component.hitByMarketing = math.max(marketingValueUglyGlobal, (component.hitByMarketing or 0))
	return 1
end

local rayTests = {}
for i = 1, 16 do
	rayTests[i] = util.Mult(100, util.RotateVector({0 , 1}, i*math.pi/12))
end

local function CheckAdjacency(self, world)
	local bx, by = self.body:getWorldCenter()
	local physicsWorld = world.GetPhysicsWorld()
	
	local power = 2
	for i = 1, #rayTests do
		local rayPos = util.Add({bx, by}, rayTests[i])
		wasHitSum = 0
		ignoreHitIndexUglyGlobal = self.index
		marketingValueUglyGlobal = self.def.marketingValue
		physicsWorld:rayCast(bx, by - 15, rayPos[1], rayPos[2], HitTest)
	end
end

return {
	maxNumberOfVertices = 8,
	minSize = 80,
	maxSize = 100,
	foregroundImage = "office_icon",
	backgroundImage = "office",
	borderImage = "office",
	borderThickness = 40,
	CheckAdjacency = CheckAdjacency,
	seaDamage = 0.05,
	marketingValue = 0.2
}
