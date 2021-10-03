
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
	
	local wantedScale = math.max(right - left, bottom - top)
	local wantedPos = {(left + right)/2, (top + bottom)/2}
	print(wantedScale, (left + right)/2, (top + bottom)/2)
	
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
	
	cameraTransform:setTransformation(
		windowX/2, windowY/2, 0,
		boundLimit/cameraScale, boundLimit/cameraScale,
		cameraX, cameraY)
end

local function Initialize()
	self = {
		cameraPos = {0, 0},
		cameraVelocity = {0, 0},
		posVelocity = {0, 0},
		cameraScale = 0.93,
	}
end

return {
	UpdateCameraToPlayer = UpdateCameraToPlayer,
	UpdateCameraToViewPoints = UpdateCameraToViewPoints,
	UpdateTransform = UpdateTransform,
	Initialize = Initialize,
}
