
local IterableMap = require("include/IterableMap")
local util = require("include/util")

local Resources = require("resourceHandler")

local self = {}
local api = {}

local dTotal = 0

function api.Update(dt)
	-- IterableMap.ApplySelf(self.components, "Update", dt)
	dTotal = dTotal + dt

	for i = 1, #self.waveCoordinates do
		local xSway = self.randomWaveMagSpeed[i][1] * math.cos(dTotal * self.randomWaveMagSpeed[i][3])
		local ySway = self.randomWaveMagSpeed[i][2] * math.sin(dTotal * self.randomWaveMagSpeed[i][4])
		self.waveCoordinates[i][1] = self.waveCoordinates[i][1] + xSway
		self.waveCoordinates[i][2] = self.waveCoordinates[i][2] + ySway
	end

end

function api.Draw(drawQueue)
	drawQueue:push({y=0; f=function()
		love.graphics.push()
			local x, y = self.body:getPosition()
			local angle = self.body:getAngle()
			
			Resources.DrawImage("island", x, y)

			love.graphics.translate(x, y)
			love.graphics.rotate(angle)
			--for s = 1, #self.coordSets do
			--	local coords = self.coordSets[s]
			--	for i = 1, #coords do
			--		local other = coords[(i < #coords and (i + 1)) or 1]
			--		love.graphics.line(coords[i][1], coords[i][2], other[1], other[2])
			--	end
			--end
		love.graphics.pop()
	end})

	for i = 1, #self.randomDepth do
		drawQueue:push({y=self.randomDepth[i]; f=function()
			love.graphics.push()
			Resources.DrawImage("waves", self.waveCoordinates[i][1], self.waveCoordinates[i][2], 0, self.randomAlpha[i], self.randomScale[i])
			love.graphics.pop()
		end})
	end

	drawQueue:push({y=-10; f=function()
		love.graphics.push()
			local x, y = self.body:getPosition()
			Resources.DrawImage("sky", x, y + 300)
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

	local numberOfWaves = 7
	local leftWaveCoord = 400
	local downWaveCoord = 850

	self.waveCoordinates = {}
	self.randomDepth = {}
	self.randomAlpha = {}
	self.randomScale = {}
	self.randomWaveMagSpeed = {}

	for i = 1, numberOfWaves do
		self.waveCoordinates[i] = {leftWaveCoord + (700 * (math.random() - 0.5)), downWaveCoord + (200 * (math.random() - 0.5))}
		self.randomDepth[i] = (math.random() - 0.5)
		self.randomAlpha[i] = (0.5* math.random()) + 0.1
		self.randomScale[i] = {0.6 * math.random()+ 0.4, 0.6 * math.random() + 0.4}
		self.randomWaveMagSpeed[i] = {math.random() * 2, math.random() * 2, (math.random() * 2) + 1, (math.random() * 2) + 1}
	end

	
	local lowerExtent = 200
	local coordinates = {
		{-20, 50},
		{4, 0},
		{18, -3},
		{45, -7.5},
		{100, -10},
		{275, -12},
		{450, -10},
		{505, -7.5},
		{532, -3},
		{546, 0},
		{570, 50},
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
			newFixture:setFriction(0.5)
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
