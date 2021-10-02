
local IterableMap = require("include/IterableMap")
local util = require("include/util")

local self = {}
local api = {}

function api.Update(dt)
	IterableMap.ApplySelf(self.components, "Update", dt)
end

function api.Draw(drawQueue)
	drawQueue:push({y=0; f=function()
		love.graphics.push()
			local x, y = self.body:getPosition()
			local angle = self.body:getAngle()
			love.graphics.translate(x, y)
			love.graphics.rotate(angle)
			for s = 1, #self.coordSets do
				local coords = self.coordSets[s]
				for i = 1, #coords do
					local other = coords[(i < #coords and (i + 1)) or 1]
					love.graphics.line(coords[i][1], coords[i][2], other[1], other[2])
				end
			end
		love.graphics.pop()
	end})
	if DRAW_DEBUG then
		love.graphics.circle('line',self.pos[1], self.pos[2], def.radius)
	end
end

function api.Initialize(physics)
	self.pos = {560, 780}
	self.shapes = {}
	self.fixtures = {}
	
	local lowerExtent = 200
	local coordinates = {
		{-290, 10},
		{-203, -40},
		{-180, -46},
		{-92, -51},
		{-68, -47},
		{0, -45},
		--{21, -41},
		--{51, -78},
		--{74, -116},
		--{85, -118},
		--{99, -111},
		--{104, -94},
		--{116, -97},
		--{112, -87},
		--{128, -103},
		--{129, -127},
		--{147, -125},
		--{161, -112},
		--{178, -37},
		--{243, -15},
		--{247, -12},
		--{280, 5},
	}
	
	self.body = love.physics.newBody(physics.GetPhysicsWorld(), self.pos[1], self.pos[2], "static")
	self.coordSets = {}
	
	local modCoords = {}
	local thisCoordSet = {}
	local i = 1
	while i <= #coordinates do
		local coord = coordinates[i]
		if #modCoords == 0 then
			thisCoordSet[#thisCoordSet + 1] = {coord[1], lowerExtent}
			modCoords[#modCoords + 1] = coord[1]
			modCoords[#modCoords + 1] = lowerExtent
		end
		thisCoordSet[#thisCoordSet + 1] = coord
		modCoords[#modCoords + 1] = coord[1]
		modCoords[#modCoords + 1] = coord[2]
		if #modCoords == 14 or i == #coordinates then
			thisCoordSet[#thisCoordSet + 1] = {coord[1], lowerExtent}
			modCoords[#modCoords + 1] = coord[1]
			modCoords[#modCoords + 1] = lowerExtent
			
			self.coordSets[#self.coordSets + 1] = thisCoordSet
			thisCoordSet = {}
			
			local newShape = love.physics.newPolygonShape(unpack(modCoords))
			local newFixture = love.physics.newFixture(self.body, newShape, 10)
			newFixture:setFriction(0.9)
			self.shapes[#self.shapes + 1] = newShape
			self.fixtures[#self.fixtures + 1] = newFixture
			modCoords = {}
			if i == #coordinates then
				i = i + 1
			end
		else
			i = i + 1
		end
	end
end

return api
