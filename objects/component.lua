
local util = require("include/util")
local Resources = require("resourceHandler")
local Font = require("include/font")

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

local function CalculateCentralRadius(self)
	local unpackedCoords = {}
	for i = 1, #self.coords do
		unpackedCoords[2*i - 1] = self.coords[i][1]
		unpackedCoords[2*i] = self.coords[i][2]
	end

	local isConvex = love.math.isConvex(unpackedCoords)
	local magnitudes = {}

	if isConvex == false then
		for i = 1, #self.coords do
			magnitudes[i],_ = util.CartToPolar(self.coords[i])
		end
		return math.min(unpack(magnitudes))
	end

	local x, y = self.body:getLocalCenter()
	for i = 1, #self.coords-1 do
		magnitudes[i] = util.DistanceToBoundedLine2({x,y}, {self.coords[i],self.coords[i+1]})
	end
	return math.min(unpack(magnitudes))
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

	self.imageRadius = CalculateCentralRadius(self)
	
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
	
	self.body:setLinearDamping(0)
	self.body:setAngularDamping(0.02)
end

local function MoveToMouse(self)
	if not self.mouseJoint then
		local mousePos = self.world.GetMousePosition()
		self.mouseJoint = love.physics.newMouseJoint(self.body, mousePos[1], mousePos[2])
		self.body:setAngularDamping(6)
		if PowerupHandler.AllowSelectSound() then
			SoundHandler.PlaySound("obj_grab")
		end
	end
	local mousePos = self.world.GetMousePosition()
	self.mouseJoint:setTarget(mousePos[1], mousePos[2])

	if love.keyboard.isDown("space") or love.keyboard.isDown("d") or love.keyboard.isDown("x") or love.keyboard.isDown("right") then
		self.body:setAngularVelocity(4)
	elseif love.keyboard.isDown("a") or love.keyboard.isDown("z") or love.keyboard.isDown("left") then
		self.body:setAngularVelocity(-4)
	else
		self.body:setAngularVelocity(self.body:getAngularVelocity()*0.2)
	end
end

local function ReleaseMouse(self)
	if self.mouseJoint then
		self.mouseJoint:destroy()
		self.mouseJoint = nil
		if PowerupHandler.AllowSelectSound() then
			SoundHandler.PlaySound("obj_letgo")
		end
	end
	self.body:setAngularDamping(0.02)
	self.body:setGravityScale(1)
	self.overSpeed = true
	self.mouseAnchor = false
end

local function SetupMeshes(self)
	-- Background/interior
	local meshCoords = {{0,0, 0, 0}}
	local vertex = 1
	for i = 1, #self.coords do
		meshCoords[#meshCoords + 1] = {self.coords[i][1], self.coords[i][2], vertex, 0.5}
		vertex = 1 - vertex
	end
	meshCoords[#meshCoords + 1] = {self.coords[1][1], self.coords[1][2], vertex, 0.5}
	
	self.mesh = love.graphics.newMesh(meshCoords, "fan")
	Resources.SetTexture(self.mesh, self.def.backgroundImage)
	
	-- Border
	--meshCoords = {}
	--vertex = 1
	--for i = 1, #self.coords + 1 do
	--	i = (i-1)%(#self.coords) + 1
	--	local inPoint = util.Subtract(self.coords[i], util.SetLength(self.def.borderThickness, self.coords[i]))
	--	meshCoords[#meshCoords + 1] = {inPoint[1], inPoint[2], vertex, 0}
	--	meshCoords[#meshCoords + 1] = {self.coords[i][1], self.coords[i][2], vertex, 1}
	--	vertex = 1 - vertex
	--end
	--
	--self.borderMesh = love.graphics.newMesh(meshCoords, "strip")
	--Resources.SetTexture(self.borderMesh, self.def.borderImage)
end

local function UpdateJoints(self)
	if self.dead or (not self.jointData) then
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
				data.stressSadness = false
				if minStress > data.strength then
					data.stressSadness = math.min(data.maxStretch, minStress - data.strength)
					data.joint:setMaxLength(data.joint:getMaxLength() + data.stressSadness)
				elseif minStress < data.restore and data.joint:getMaxLength() > data.desiredLength then
					data.joint:setMaxLength(data.joint:getMaxLength() - 0.05*(1 - minStress/data.restore))
				end
			end
		end
	end
end

local function StickToContacts(self)
	if Global.CONTACT_FORCE <= 0 then
		return
	end
	
	self.forceIndex = (self.forceIndex or 0)%Global.FORCE_STORE + 1
	self.forceStore = self.forceStore or {}
	
	local contactList = self.body:getContacts()
	local currentStore = {}
	for i = 1, #contactList do
		local contact = contactList[i]
		if contact:isTouching() then
			--local x1, y1, x2, y2 = contact:getPositions()
			local nx, ny = contact:getNormal()
			nx, ny = nx*Global.CONTACT_FORCE*(self.def.stickiness or 1), ny*Global.CONTACT_FORCE*(self.def.stickiness or 1)
			currentStore[#currentStore + 1] = {-nx, -ny}
		end
	end
	self.forceStore[self.forceIndex] = currentStore
	
	for i = 1, #self.forceStore do
		for j = 1, #self.forceStore[i] do
			local force = self.forceStore[i][j]
			self.body:applyForce(force[1], force[2])
		end
	end
end

local function SpeedLimit(self)
	local vx, vy = self.body:getLinearVelocity()
	local velocity = {vx, vy}
	if vy > 0 or util.AbsVal(velocity) < Global.SPEED_LIMIT then
		return
	end
	local speed = util.AbsVal(velocity)
	velocity = util.Mult(0.95, velocity)
	self.body:setLinearVelocity(velocity[1], velocity[2])
end

local function IsOverspeed(self)
	if self.mouseAnchor then
		self.overSpeed = false
		return false
	end
	if self.overSpeed then
		local contacts = self.body:getContacts()
		if #contacts == 0 then
			return true
		end
		for i = 1, #contacts do
			if contacts[i]:isTouching() then
				local fixtureA, fixtureB = contacts[i]:getFixtures()
				if fixtureA and fixtureB then
					local compA, compB = fixtureA:getUserData(), fixtureB:getUserData()
					if (not compA or not compA.overSpeed) or (not compB or not compB.overSpeed) then
						self.overSpeed = false
					end
				end
			end
		end
		if self.overSpeed then
			return true
		end
	end
	local vx, vy = self.body:getLinearVelocity()
	if util.AbsVal({vx, vy}) > Global.VIEW_SPEED_LIMIT then
		self.overSpeed = true
		return true
	end
	return false
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
		if self.def.GenerateEnergy and not self.inShop and not IsOverspeed(self) then
			self.def.GenerateEnergy(self, world, AggFunc)
		end
	end
	
	function self.GenerateEnergy_Post(AggFunc)
		if self.def.GenerateEnergy_Post and not self.inShop and not IsOverspeed(self) then
			self.def.GenerateEnergy_Post(self, world, AggFunc)
		end
	end
	
	function self.ResetAggregators(AggFunc)
		if self.def.ResetAggregators and not self.inShop then
			self.def.ResetAggregators(self, world, AggFunc)
		end
	end
	
	function self.CheckAdjacency(AggFunc)
		if self.def.CheckAdjacency and not self.inShop and not IsOverspeed(self) then
			self.def.CheckAdjacency(self, world, AggFunc)
		end
	end
	
	function self.CheckAdjacency_Post(AggFunc)
		if self.def.CheckAdjacency_Post and not self.inShop and not IsOverspeed(self) then
			self.def.CheckAdjacency_Post(self, world, AggFunc)
		end
	end
	
	function self.AddToView(viewPoints)
		if self.dead or self.inShop or self.mouseJoint then
			return
		end
		if IsOverspeed(self) and not Global.YEET then
			return
		end
		local bx, by = self.body:getWorldCenter()
		viewPoints[#viewPoints + 1] = {bx, by}
	end
	
	function self.Update(dt)
		self.animTime = self.animTime + dt*(self.animSpeed or self.def.animSpeed or 0)
		if self.mouseAnchor then
			MoveToMouse(self)
		elseif self.inShop then
			self.body:setAngularVelocity(1)
		end
		
		SpeedLimit(self)
		UpdateJoints(self)
		StickToContacts(self)
		
		local bx, by = self.body:getPosition()
		if by > Global.SEA_DEATH and not self.inShop and not self.mouseAnchor then
			self.Destroy()
			GameHandler.AddSeaDamage(self.def.seaDamage)
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
			end
			return
		end
		if self.inShop then
			ShopHandler.ItemSelected(self)
			for i = 1, #self.fixtures do
				self.fixtures[i]:setMask()
			end
			local AggFunc = ComponentHandler.AddEnergy
			self.ResetAggregators(AggFunc)
			self.CheckAdjacency(AggFunc)
			self.CheckAdjacency_Post(AggFunc)
			self.GenerateEnergy(AggFunc)
		end
		local bx, by = self.body:getPosition()
		local angle = self.body:getAngle()
		local bodyPoint = {bx, by}
		local mousePoint = {x, y}
		self.mouseAnchor = util.RotateVector(util.Subtract(mousePoint, bodyPoint), -angle)
		self.body:setGravityScale(0)
		for i = 1, #self.fixtures do
			self.fixtures[i]:setFriction(self.def.friction or 0.99)
		end
	end
	
	function self.Draw(drawQueue)
		drawQueue:push({y = (self.inShop and Global.PIECE_DRAW_ORDER_SHOP) or Global.PIECE_DRAW_ORDER;
			f = function()
			love.graphics.push()
				local x, y = self.body:getPosition()
				local angle = self.body:getAngle()
				love.graphics.translate(x, y)
				love.graphics.rotate(angle)
				
				if self.def.nuclearDisables and (self.hitByNuclear or 0) > 0 then
					love.graphics.setColor(0.78,0.78,0.78)
				else
					love.graphics.setColor(1,1,1)
				end
				love.graphics.draw(self.mesh)
					love.graphics.setColor(1,1,1)
				--love.graphics.draw(self.borderMesh)

				love.graphics.setLineWidth(3)
				for i = 1, #self.coords do
					local other = self.coords[(i < #self.coords and (i + 1)) or 1]
					love.graphics.line(self.coords[i][1], self.coords[i][2], other[1], other[2])
				end

				--if self.drawSplit then
				--	for s = 1, #self.drawSplit do
				--		local split = self.drawSplit[s]
				--		for i = 1, #split do
				--			local other = split[(i < #split and (i + 1)) or 1]
				--			love.graphics.line(split[i][1], split[i][2], other[1], other[2])
				--		end
				--	end
				--end

				love.graphics.setLineWidth(1)

			love.graphics.pop()
			
			if self.def.foregroundImage then
				local bx, by = self.body:getWorldCenter()
				--Resources.DrawImage(self.def.foregroundImage, math.floor(bx), math.floor(by), 0, 1, self.imageRadius/100)
				Resources.DrawImage(self.def.foregroundImage, bx, by, self.animTime or 0, 1, self.imageRadius/100)
			end
		end})
		
		drawQueue:push({y = Global.LINK_DRAW_ORDER;
			f = function()
			if self.jointData then
				for i = 1, #self.jointData do
					local data = self.jointData[i]
					if not data.endComponent.dead then
						local startPos = self.LocalToWorld(data.startPos)
						local endPos = data.endComponent.LocalToWorld(data.endPos)
						local linkVector = util.Subtract(endPos, startPos)
						local length = data.joint:getMaxLength()
						local thickness = math.min(1, data.desiredLength / (length and length > 0 and length) or 1)
						Resources.DrawImage(data.image, startPos[1], startPos[2], util.Angle(linkVector), 1, {util.AbsVal(linkVector)/300, 0.3 + 0.7*thickness})
						
						if data.stressSadness then
							local prop = data.stressSadness/data.maxStretch
							love.graphics.setLineWidth(13*(0.5 + 0.5*data.stressSadness))
							love.graphics.setColor(1,0,0,0.1 + 0.2*data.stressSadness)
							love.graphics.line(startPos[1], startPos[2], endPos[1], endPos[2])
							love.graphics.setLineWidth(1)
						end
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
