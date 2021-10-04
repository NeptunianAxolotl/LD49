
local IterableMap = require("include/IterableMap")
local util = require("include/util")

local Resources = require("resourceHandler")

local self = {}
local api = {}

local dTotal = 0
-- island queue rank
local iQR = 3

local function GetSeaColor(prop)
	return self.baseSeaColor
end

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
	drawQueue:push({y=iQR; f=function()
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
	
	local windowX, windowY = love.window.getMode()
	local sideScaleMult = math.max(1, (windowX / windowY) * (Camera.GetCameraScale() / 3000))
	for i = 1, #self.randomDepth do
		local seaColor = GetSeaColor(GameHandler.GetSeaDamage())
		drawQueue:push({y=self.randomDepth[i]; f=function()
			love.graphics.push()
			local scale = self.randomScale[i]
			if sideScaleMult > 1 then
				scale = {scale[1]*sideScaleMult, scale[2]}
			end
			
			Resources.DrawImage("waves", self.waveCoordinates[i][1], self.waveCoordinates[i][2], 0, self.randomAlpha[i], scale, seaColor)
			love.graphics.pop()
		end})
	end

	drawQueue:push({y=-10; f=function()
		love.graphics.push()
			local x, y = self.body:getPosition()
			local scale = false
			if sideScaleMult > 1 then
				scale = {sideScaleMult, 1}
			end
			Resources.DrawImage("sky", x, y + 300, 0, 1, scale)
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
	
	self.waveCoordinates = {{-50,830},{-100,800},{-80,900},{-140,930},{-50,740},{-200,670},{-100,700},{-20,810},{-100,790}, {-200,980}}
	for i = 1, #self.waveCoordinates do
		self.waveCoordinates[i][1] = self.waveCoordinates[i][1] + 600
	end
	
	self.randomDepth = {iQR+0.5,iQR+0.5,iQR+0.6,iQR-0.1,iQR,iQR-0.2,iQR-0.3,iQR+6,iQR+7, iQR+8}
	self.randomAlpha = {0.2,0.2,0.3,0.3,0.4,0.6,0.7,0.9,0.7, 1}
	self.randomScale = {{2,0.8},{5,0.6},{3,0.4},{6,0.5},{5,0.7},{6,0.6},{8,0.4},{4,0.4},{3,0.2},{7,0.4}}
	self.randomWaveMagSpeed = {{5,0.3,1.2,0.6},{4.3,0.3,0.7,0.9},{0.3,0.1,3,1.5},{1,0.6,1.8,1.5},{2.5,0.19,1.45,1.2},{0.6,0.15,1.3,1.},{2.2,0.2,2.5,1.2},{3,0.1,0.6,0.3},{2.5,0.2,0.9,0.4},{0.1,0.03,1,0.3}}

	self.baseSeaColor = {62/255, 114/255, 195/255}

	local lowerExtent = 200
	local islandScale = 1.08
	local coordinates = {
		{islandScale * 0, 50},
		{islandScale * 10, 0},
		{islandScale * 18, -3},
		{islandScale * 45, -7.5},
		{islandScale * 100, -10},
		{islandScale * 275, -12},
		{islandScale * 450, -10},
		{islandScale * 505, -7.5},
		{islandScale * 532, -3},
		{islandScale * 546, 0},
		{islandScale * 556, 50},
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
