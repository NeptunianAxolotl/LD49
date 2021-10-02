
local util = require("include/util")
local Resources = require("resourceHandler")
local Font = require("include/font")

local DEF = {
	density = 1,
}

local function SetupPhysicsBody(self, physicsWorld)
	self.coords = util.CopyTable(self.def.coords)
	
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

local function NewComponent(self, physicsWorld)
	-- pos
	self.animTime = 0
	
	SetupPhysicsBody(self, physicsWorld)
	
	function self.Update(dt)
		self.animTime = self.animTime + dt
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
