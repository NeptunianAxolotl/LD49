
local util = require("include/util")

local self = {}

local function UpdateCameraToPlayer(dt, playerPos, playerVelocity, playerSpeed, smoothness)
	self.cameraVelocity = util.Average(self.cameraVelocity, playerVelocity, 2*(1 - smoothness))
	self.cameraPos = util.Add(util.Mult(dt*60, self.cameraVelocity), util.Average(self.cameraPos, playerPos, (1 - smoothness)))
	
	local wantedScale = math.min(0.93, math.max(0.5, 12/(12 + playerSpeed)))
	self.cameraScale = self.cameraScale*smoothness + wantedScale*(1 - smoothness)
	
	return self.cameraPos[1], self.cameraPos[2], self.cameraScale
end

local function UpdateCameraToViewPoints(dt, pointList, radius, moveSmooth, scaleSmooth)
	if #pointList == 0 then
		return self.cameraPos[1], self.cameraPos[2], self.cameraScale
	end
	local left, right, top, bottom = pointList[1][1] - radius, pointList[1][1] + radius, pointList[1][2] - radius, pointList[1][2] + radius
	for i = 2, #pointList do
		left, right = math.min(left, pointList[i][1] - radius), math.max(right, pointList[i][1] + radius)
		top, bottom = math.min(top, pointList[i][2] - radius), math.max(bottom, pointList[i][2] + radius)
	end
	
	if self.pinY then
		if self.pinY[2] == 1 then
			bottom = self.pinY[1]
			if self.minScaleY and top > bottom - self.minScaleY then
				top = bottom - self.minScaleY
			end
		end
	end
	
	if self.pinX then
		if self.pinX[2] == 0.5 then
			local sideDiff = math.max((self.pinX[1] - left)*(1 - self.pinX[2]), (right - self.pinX[1])*self.pinX[2])
			if self.minScaleX and sideDiff < self.minScaleX then
				sideDiff = self.minScaleX
			end
			left = self.pinX[1] - sideDiff*self.pinX[2]
			right = self.pinX[1] + sideDiff*(1 - self.pinX[2])
		end
	end
	
	local wantedScale = math.max((right - left)*self.scaleMult[1], (bottom - top)*self.scaleMult[2])
	local wantedPos = {(left + right)/2, (top + bottom)/2}
	
	self.cameraVelocity = util.Average(self.cameraVelocity, self.posVelocity, (1 - moveSmooth))
	local newPos = util.Add(util.Mult(dt, self.cameraVelocity), util.Average(self.cameraPos, wantedPos, (1 - moveSmooth)))
	self.cameraScale = self.cameraScale*scaleSmooth + wantedScale*(1 - scaleSmooth)
	
	self.posVelocity = util.Subtract(newPos, self.cameraPos)
	self.cameraPos = newPos
	
	return self.cameraPos[1], self.cameraPos[2], self.cameraScale
end

local function UpdateTransform(cameraTransform, cameraX, cameraY, cameraScale)
	local windowX, windowY = love.window.getMode()
	local boundLimit = math.min(windowX, windowY)
	self.scaleMult = {boundLimit/windowX, boundLimit/windowY}
	
	if math.random() < 0.01 then
		print(boundLimit, cameraX, cameraY, cameraScale)
	end
	
	if self.pinY then
		if self.pinY[2] == 1 then
			if cameraY + cameraScale/2 > self.pinY[1] then
				cameraY = self.pinY[1] - cameraScale/2
			end
		end
	end
	cameraTransform:setTransformation(
		windowX/2, windowY/2, 0,
		boundLimit/cameraScale, boundLimit/cameraScale,
		cameraX, cameraY)
end

local function Initialize(data)
	self = {
		cameraPos = {0, 0},
		cameraVelocity = {0, 0},
		posVelocity = {0, 0},
		cameraScale = 0.93,
		pinX = data.pinX,
		pinY = data.pinY,
		minScaleX = data.minScaleX,
		minScaleY = data.minScaleY,
	}
	
	local windowX, windowY = love.window.getMode()
	local boundLimit = math.min(windowX, windowY)
	self.scaleMult = {boundLimit/windowX, boundLimit/windowY}
end

return {
	UpdateCameraToPlayer = UpdateCameraToPlayer,
	UpdateCameraToViewPoints = UpdateCameraToViewPoints,
	UpdateTransform = UpdateTransform,
	Initialize = Initialize,
}
