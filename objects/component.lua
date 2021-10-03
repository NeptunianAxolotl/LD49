
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

	if cuts[#cuts] > (2 * math.pi - sectionAngle) then
		local cleanScaling = {(2 * math.pi - sectionAngle)/cuts[#cuts], (2 * math.pi)/cuts[#cuts]}
		cuts = util.ScaleArray(cuts, math.random() * (cleanScaling[2] - cleanScaling[1]) + cleanScaling[1])
	end

	return cuts
end

local function ArbitraryBlock(sides)
	local block = {}
	local angles = RandomCut(sides, 2*math.pi/((sides - 0.5) * 2))
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

local function MakeBodyShapeFixtures(self, physicsWorld)
	self.shapes = {}
	self.fixtures = {}

	for i = 1, #self.coords do
		self.coords[i] = util.Mult(self.def.minSize + math.random()*(self.def.maxSize - self.def.minSize), self.coords[i])
	end

	local splitCoords = {}
	for i = 1, #self.coords do
		local back = self.coords[(i - 2)%#self.coords + 1]
		local front = self.coords[i%#self.coords + 1]
		local coord = self.coords[i]
		--print((i - 2)%#self.coords + 1, i, i%#self.coords + 1, #self.coords)
		
		local cross = util.Cross2D(util.Subtract(front, coord), util.Subtract(coord, back))
		if cross > 0 then
			--print("Split", i)
			splitCoords[i] = true
		end
	end
	
	local firstSplit = false
	local mirrorSplit = {}
	for i = 1, #self.coords do
		if splitCoords[(i + math.floor(#self.coords/2) - 1)%#self.coords + 1] then
			mirrorSplit[i] = true
			--print("Split Other", i)
		end
	end
	
	for i = 1, #self.coords do
		if splitCoords[i] and not firstSplit then
			firstSplit = i
		end
		if mirrorSplit[i] then
			splitCoords[i] = true
		end
	end
	
	if not firstSplit then
		local modCoords = {}
		for i = 1, #self.coords do
			modCoords[#modCoords + 1] = self.coords[i][1]
			modCoords[#modCoords + 1] = self.coords[i][2]
		end
		self.body = love.physics.newBody(physicsWorld, self.pos[1], self.pos[2], "dynamic")
		self.shapes[1] = love.physics.newPolygonShape(unpack(modCoords))
		self.fixtures[1] = love.physics.newFixture(self.body, self.shapes[1], self.def.density)
		return
	end
	
	self.body = love.physics.newBody(physicsWorld, self.pos[1], self.pos[2], "dynamic")
	
	self.drawSplit = {}
	local modCoords = {}
	local drawCoods = {}
	local i = firstSplit
	while true do
		if splitCoords[i] then
			modCoords = {}
			modCoords[#modCoords + 1] = 0
			modCoords[#modCoords + 1] = 0
			drawCoods[#drawCoods + 1] = {0, 0}
		end
		modCoords[#modCoords + 1] = self.coords[i][1]
		modCoords[#modCoords + 1] = self.coords[i][2]
		drawCoods[#drawCoods + 1] = self.coords[i]
		i = i%(#self.coords) + 1
		if splitCoords[i] then
			modCoords[#modCoords + 1] = self.coords[i][1]
			modCoords[#modCoords + 1] = self.coords[i][2]
			drawCoods[#drawCoods + 1] = self.coords[i]
			
			self.drawSplit[#self.drawSplit + 1] = drawCoods
			local shape = love.physics.newPolygonShape(unpack(modCoords))
			local fixture = love.physics.newFixture(self.body, shape, self.def.density)
			self.shapes[#self.shapes + 1] = shape
			self.fixtures[#self.fixtures + 1] = fixture
		end
		if i == firstSplit then
			break
		end
	end
	
end

local function SetupPhysicsBody(self, physicsWorld)
	self.sides = math.floor(love.math.random() * (self.def.maxNumberOfVertices - 3)) + 4
	self.coords = ArbitraryBlock(self.sides)

	MakeBodyShapeFixtures(self, physicsWorld)
	
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
		self.fixtures[i]:setRestitution(0.00)
	end
end

local function MoveToMouse(self)
	if not self.mouseJoint then
		local mousePos = self.world.GetMousePosition()
		self.mouseJoint = love.physics.newMouseJoint(self.body, mousePos[1], mousePos[2])
	end
	local mousePos = self.world.GetMousePosition()
	self.mouseJoint:setTarget(mousePos[1], mousePos[2])

	if love.keyboard.isDown("space") then
		self.body:setAngularVelocity(4)
	else
		self.body:setAngularVelocity(0)
	end
end

local function ReleaseMouse(self)
	self.body:setLinearVelocity(0, 0.01)
	self.body:setGravityScale(1)
	self.mouseAnchor = false
end

local function SetupMeshes(self)
	-- Background/interior
	local meshCoords = {{0,0, 0, 0}}
	local vertex = 1
	for i = 1, #self.coords do
		meshCoords[#meshCoords + 1] = {self.coords[i][1], self.coords[i][2], vertex, 1}
		vertex = 1 - vertex
	end
	meshCoords[#meshCoords + 1] = {self.coords[1][1], self.coords[1][2], 1, vertex}
	
	self.mesh = love.graphics.newMesh(meshCoords, "fan")
	Resources.SetTexture(self.mesh, self.def.backgroundImage)
	
	-- Border
	meshCoords = {}
	vertex = 1
	for i = 1, #self.coords + 1 do
		i = (i-1)%(#self.coords) + 1
		local inPoint = util.Subtract(self.coords[i], util.SetLength(self.def.borderThickness, self.coords[i]))
		meshCoords[#meshCoords + 1] = {inPoint[1], inPoint[2], vertex, 0}
		meshCoords[#meshCoords + 1] = {self.coords[i][1], self.coords[i][2], vertex, 1}
		vertex = 1 - vertex
	end
	
	self.borderMesh = love.graphics.newMesh(meshCoords, "strip")
	Resources.SetTexture(self.borderMesh, self.def.borderImage)
end

local function UpdateJoints(self)
	if not self.jointData then
		return
	end
	
	for i = 1, #self.jointData do
		local data = self.jointData[i]
		if not data.endComponent.dead then
			local x, y = data.joint:getReactionForce(0.033)
			local stress = util.AbsVal({x, y})
			data.stressIndex = (data.stressIndex or 0)%Global.STRESS_AVE_TIME + 1
			data.stressRem = data.stressRem or {}
			data.stressRem[data.stressIndex] = stress
			if #data.stressRem == Global.STRESS_AVE_TIME then
				local minStress = stress
				for j = 1, #data.stressRem do
					if data.stressRem[j] < stress then
						minStress = data.stressRem[j]
					end
				end
				if data.strength > data.strength then
					data.joint:setMaxLength(data.joint:getMaxLength() + math.min(data.strength + 1, minStress - data.strength))
				elseif minStress < data.restore and data.joint:getMaxLength() > data.desiredLength then
					data.joint:setMaxLength(data.joint:getMaxLength() - 0.15)
				end
			end
		end
	end
end

local function NewComponent(self, world)
	-- pos
	self.animTime = 0
	self.world = world

	SetupPhysicsBody(self, world.GetPhysicsWorld())
	SetupMeshes(self)

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
	
	function self.AddToView(viewPoints)
		if self.dead or self.inShop or self.mouseJoint then
			return
		end
		local bx, by = self.body:getWorldCenter()
		viewPoints[#viewPoints + 1] = {bx, by}
	end
	
	function self.Update(dt)
		self.animTime = self.animTime + dt
		if self.mouseAnchor then
			MoveToMouse(self)
		elseif self.mouseJoint then
			self.mouseJoint:destroy()
			self.mouseJoint = nil
		elseif self.inShop then
			self.body:setAngularVelocity(1)
		end
		
		UpdateJoints(self)
		
		local bx, by = self.body:getPosition()
		if by > 1020 then
			self.Destroy()
			return true -- Destroy
		end
	end
	
	function self.ClickTest(x, y, noShop)
		if (not self.dead) and self.inShop and noShop then
			return
		end
		for i = 1, #self.fixtures do
			if self.fixtures[i]:testPoint(x, y) then
				return true
			end
		end
		return false
	end
	
	function self.WorldToLocal(pos)
		local bx, by = self.body:getWorldCenter()
		local angle = self.body:getAngle()
		return util.RotateVector(util.Subtract(pos, {bx, by}), -angle)
	end
	
	function self.LocalToWorld(pos)
		local bx, by = self.body:getWorldCenter()
		local angle = self.body:getAngle()
		return util.Add(util.RotateVector(pos, angle), {bx, by})
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

				love.graphics.draw(self.mesh)
				love.graphics.draw(self.borderMesh)

				love.graphics.setColor(1,1,1)
				love.graphics.setLineWidth(2)

				if self.drawSplit then
					for s = 1, #self.drawSplit do
						local split = self.drawSplit[s]
						for i = 1, #split do
							local other = split[(i < #split and (i + 1)) or 1]
							love.graphics.line(split[i][1], split[i][2], other[1], other[2])
						end
					end
				end

				love.graphics.setLineWidth(1)

			love.graphics.pop()
			
			if self.jointData then
				for i = 1, #self.jointData do
					local data = self.jointData[i]
					if not data.endComponent.dead then
						local startPos = self.LocalToWorld(data.startPos)
						local endPos = data.endComponent.LocalToWorld(data.endPos)
						local x, y = data.joint:getReactionForce(0.033)
						love.graphics.setLineWidth(1 + util.AbsVal({x, y}))
						love.graphics.line(startPos[1], startPos[2], endPos[1], endPos[2])
						love.graphics.setLineWidth(1)
					end
				end
			end
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
