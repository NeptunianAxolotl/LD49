
local util = require("include/util")
local Resources = require("resourceHandler")
local Font = require("include/font")

local DEF = {
	density = 1,
}

local function RandomCut(sections, minAngle)
	local cuts = {0}
	local sectionAngle = 2 * math.pi/sections
	-- local runningAngle = cuts[1]

	for i = 1, sections - 1 do
		-- First parenthesis to guarantee that we don't overshoot 2 pi over N sides.
		cuts[i + 1] = (minAngle + ((i * sectionAngle - minAngle - cuts[i]) * math.random())) + cuts[i]
		-- runningAngle = runningAngle + cuts[i + 1]
	end

	if cuts[#cuts] < (2 * math.pi - sectionAngle) then
		local cleanScaling = {(2 * math.pi - sectionAngle)/cuts[#cuts], (2 * math.pi)/cuts[#cuts]}
		cuts = util.ScaleArray(cuts, math.random() * (cleanScaling[2] - cleanScaling[1]) + cleanScaling[1])
	end

	return cuts
end

local function ArbitraryBlock(sides)
	local block = {}
	local angles = RandomCut(sides, 2*math.pi/(sides * 2))
	local magnitudes = {}

	for i = 1, #angles do
		magnitudes[i] = math.max(love.math.random(), 0.5)
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

	self.shapes = {}
	self.fixtures = {}

	local modCoords = {}
	for i = 1, #self.coords do
		local pos = util.Mult(self.def.minSize + math.random()*(self.def.maxSize - self.def.minSize), self.coords[i])
		modCoords[#modCoords + 1] = pos[1]
		modCoords[#modCoords + 1] = pos[2]
		self.coords[i] = pos
	end
	self.body = love.physics.newBody(physicsWorld, self.pos[1], self.pos[2], "dynamic")
	self.shapes[1] = love.physics.newPolygonShape(unpack(modCoords))
	self.fixtures[1] = love.physics.newFixture(self.body, self.shapes[1], self.def.density)
	
	if self.initVelocity then
		self.body:setLinearVelocity(self.initVelocity[1], self.initVelocity[2])
	else
		self.body:setLinearVelocity(0, 0)
	end
	
	if self.inShop then
		self.body:setGravityScale(0)
		for i = 1, #self.fixtures do
			self.fixtures[i]:setMask(1)
		end
	end
	
	for i = 1, #self.fixtures do
		self.fixtures[i]:setUserData(self)
	end
end

local function MoveToMouse(self)
	local bx, by = self.body:getPosition()
	local massX, massY = self.body:getWorldCenter()
	local angle = self.body:getAngle()
	local anchorPoint = util.Add({bx, by}, util.RotateVector(self.mouseAnchor, angle))
	
	local mx, my = love.mouse.getPosition()
	local forceVector = util.Subtract({mx, my}, anchorPoint)
	local mouseDist = util.AbsVal(forceVector)
	
	local forceMult = util.SmoothStep(0.2, 200, mouseDist)*100
	
	local mouseDiff = util.Mult(forceMult, util.Unit(util.Subtract({mx, my}, anchorPoint)))
	self.body:setLinearVelocity(mouseDiff[1], mouseDiff[2])
	
	if love.keyboard.isDown("space") then
		self.body:setAngularVelocity(4)
	else
		self.body:setAngularVelocity(0)
	end

	local mouseSnap = util.Subtract({mx, my}, util.RotateVector(self.mouseAnchor, angle))
	self.body:setPosition(mouseSnap[1], mouseSnap[2])
end

local function ReleaseMouse(self)
	self.body:setLinearVelocity(0, 0.01)
	self.body:setGravityScale(1)
	self.mouseAnchor = false
end

local function NewComponent(self, world)
	-- pos
	self.animTime = 0
	
	SetupPhysicsBody(self, world.GetPhysicsWorld())
	
	
	function self.IsDestroyed()
		return self.dead
	end
	
	function self.IsInShop()
		return self.inShop
	end
	
	function self.SetComponentPosition(pos)
		self.body:setPosition(pos[1], pos[2])
	end
	
	function self.GenerateEnergy(AggFunc)
		if self.def.EnergyFunc and not self.inShop then
			self.def.EnergyFunc(self, world, AggFunc)
		end
	end
	
	function self.Update(dt)
		self.animTime = self.animTime + dt
		if self.mouseAnchor then
			MoveToMouse(self)
		end
	end
	
	function self.ClickTest(x, y)
		if self.inShop and not ShopHandler.ShopSelectAllowed() then
			return
		end
		for i = 1, #self.fixtures do
			if self.fixtures[i]:testPoint(x, y) then
				return true
			end
		end
		return false
	end
	
	function self.SetMouseAnchor(x, y)
		if not x then
			if self.mouseAnchor then
				ReleaseMouse(self)
				self.body:setLinearDamping(0)
				self.body:setAngularDamping(0)
			end
			return
		end
		if self.inShop then
			ShopHandler.ItemSelected(self)
			for i = 1, #self.fixtures do
				self.fixtures[i]:setMask()
			end
		end
		local bx, by = self.body:getPosition()
		local angle = self.body:getAngle()
		local bodyPoint = {bx, by}
		local mousePoint = {x, y}
		self.mouseAnchor = util.RotateVector(util.Subtract(mousePoint, bodyPoint), -angle)
		self.body:setLinearDamping(0.2)
		self.body:setAngularDamping(0.2)
		self.body:setGravityScale(0)
		for i = 1, #self.fixtures do
			self.fixtures[i]:setFriction(self.def.friction or 0.85)
		end
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
	
	function self.Destroy()
		if not self.dead then
			for i = 1, #self.fixtures do
				self.fixtures[i]:setUserData(nil)
			end
			self.body:destroy()
			self.dead = true
		end
	end
	return self
end

return NewComponent
