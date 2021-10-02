
local util = require("include/util")
local Resources = require("resourceHandler")
local Font = require("include/font")

local DEF = {
	density = 1,
}

local function RandomCut(sections, mag)
	local cuts = {}
	for i = 1, sections do
		cuts[i] = love.math.random() * mag
	end
	table.sort(cuts)
	return cuts
end

local function ArbitraryBlock(sides)
	local block = {}
	local angles = RandomCut(sides, 2*math.pi)
	local magnitudes = {}

	for i = 1, #angles do
		magnitudes[i] = love.math.random()
	end

	local invMaxMag = 1/math.max(unpack(magnitudes))
	magnitudes = util.ScaleArray(magnitudes, invMaxMag)

	for i = 1, #magnitudes do
		block[i] = util.PolarToCart(magnitudes[i], angles[i])
	end

	return block
end

local function SetupPhysicsBody(self, physicsWorld)
	self.sides = math.floor(love.math.random() * (self.def.maxNumberOfVertices - 2)) + 3
	self.coords = ArbitraryBlock(self.sides)

	local angle = util.GetRandomAngle()
	local modCoords = {}
	for i = 1, #self.coords do
		local pos = util.Mult(self.def.minSize + math.random()*(self.def.maxSize - self.def.minSize), self.coords[i])
		pos = util.RotateVector(pos, angle)
		modCoords[#modCoords + 1] = pos[1]
		modCoords[#modCoords + 1] = pos[2]
		self.coords[i] = pos
	end
	self.body = love.physics.newBody(physicsWorld, self.pos[1], self.pos[2], "dynamic")
	self.shape = love.physics.newPolygonShape(unpack(modCoords))
	self.fixture = love.physics.newFixture(self.body, self.shape, self.def.density)
	
	if self.initVelocity then
		self.body:setLinearVelocity(self.initVelocity[1], self.initVelocity[2])
	end
end

local function MoveToMouse(self)
	local bx, by = self.body:getPosition()
	local angle = self.body:getAngle()
	local anchorPoint = util.Add({bx, by}, util.RotateVector(self.mouseAnchor, angle))
	
	local mx, my = love.mouse.getPosition()
	local forceVector = util.Subtract({mx, my}, anchorPoint)
	local mouseDist = util.AbsVal(forceVector)
	
	local forceMult = util.SmoothStep(0.2, 200, mouseDist)*100
	print(forceMult)
	
	local mouseDiff = util.Mult(forceMult * self.body:getMass(), util.Unit(util.Subtract({mx, my}, anchorPoint)))
	self.body:setLinearVelocity(mouseDiff[1], mouseDiff[2])

	local mouseSnap = util.Subtract({mx, my}, util.RotateVector(self.mouseAnchor, angle))
	self.body:setPosition(mouseSnap[1], mouseSnap[2])
end

local function ReleaseMouse(self)
	self.body:setLinearVelocity(0, 0)
	self.body:setGravityScale(1)
	self.mouseAnchor = false
end

local function NewComponent(self, physicsWorld)
	-- pos
	self.animTime = 0
	
	SetupPhysicsBody(self, physicsWorld)
	
	function self.Update(dt)
		self.animTime = self.animTime + dt
		if self.mouseAnchor then
			MoveToMouse(self)
		end
	end
	
	function self.ClickTest(x, y)
		if not self.fixture:testPoint(x, y) then
			return
		end
		return true
	end
	
	function self.SetMouseAnchor(x, y)
		if not x then
			if self.mouseAnchor then
				ReleaseMouse(self)
			end
			--self.body:setLinearDamping(0)
			--self.body:setAngularDamping(0)
			return
		end
		local bx, by = self.body:getPosition()
		local angle = self.body:getAngle()
		local bodyPoint = {bx, by}
		local mousePoint = {x, y}
		self.mouseAnchor = util.RotateVector(util.Subtract(mousePoint, bodyPoint), -angle)
		--self.body:setLinearDamping(0.2)
		--self.body:setAngularDamping(0.2)
		self.body:setGravityScale(0)
	end
	
	function self.Draw(drawQueue)
		drawQueue:push({y=0; f=function()
			love.graphics.push()
				local x, y = self.body:getPosition()
				local angle = self.body:getAngle()
				love.graphics.translate(x, y)
				love.graphics.rotate(angle)
				for i = 1, #self.coords do
					local other = self.coords[(i < #self.coords and (i + 1)) or 1]
					love.graphics.line(self.coords[i][1], self.coords[i][2], other[1], other[2])
				end
			love.graphics.pop()
		end})
		if DRAW_DEBUG then
			love.graphics.circle('line',self.pos[1], self.pos[2], def.radius)
		end
	end
	
	function self.DrawInterface()
		
	end
	
	return self
end

return NewComponent
