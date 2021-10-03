
local util = require("include/util")

local EffectsHandler = require("effectsHandler")
local ComponentHandler = require("componentHandler")
local Resources = require("resourceHandler")

local self = {}
local world

local powerupList = {
	"rope",
}

local currentPowerup = false
local firstClicked = false
local firstClickedPos = false

--------------------------------------------------
-- API
--------------------------------------------------

local function DoPowerupMouseAction(x, y)
	if not currentPowerup then
		return
	end
	local component = ComponentHandler.GetComponentAt(x, y, true)
	if not component then
		return
	end
	if firstClicked and firstClicked.dead then
		firstClicked = false
	end
	if not firstClicked then
		firstClicked = component
		firstClickedPos = component.WorldToLocal({x, y})
		return
	end
	if firstClicked.index == component.index then
		return
	end
	
	local firstPos = firstClicked.LocalToWorld(firstClickedPos)
	local ropeLength = util.Dist(firstPos, {x, y})
	local joint = love.physics.newRopeJoint(firstClicked.body, component.body, firstPos[1], firstPos[2], x, y, ropeLength, true)
	
	firstClicked.jointData = firstClicked.jointData or {}
	firstClicked.jointData[#firstClicked.jointData + 1] = {
		joint = joint,
		desiredLength = ropeLength,
		startPos = firstClickedPos,
		endComponent = component,
		endPos = component.WorldToLocal({x, y}),
		strength = 0.95,
		restore = 0.01,
	}
	
	currentPowerup = false
	firstClicked = false
	firstClickedPos = false
end

--------------------------------------------------
-- API
--------------------------------------------------

function self.GetRandomPowerup()
	return util.SampleList(powerupList)
end

function self.SelectPowerup(powerupType)
	currentPowerup = powerupType
end

function self.MousePressed(x, y)
	DoPowerupMouseAction(x, y)
end

function self.MouseReleased(x, y)
	DoPowerupMouseAction(x, y)
end

function self.DrawPowerup(drawQueue, powerupType, pos)
	drawQueue:push({y=0; f=function()
		Resources.DrawImage(powerupType, pos[1], pos[2], self.animDt)
	end})
end

--------------------------------------------------
-- Updating
--------------------------------------------------

function self.Update(dt)
	self.animDt = self.animDt + dt
end

function self.Draw(drawQueue)
	if firstClicked and not firstClicked.dead then
		local firstPos = firstClicked.LocalToWorld(firstClickedPos)
		local mousePos = world.GetMousePosition()
		drawQueue:push({y=0; f=function()
			love.graphics.line(firstPos[1], firstPos[2], mousePos[1], mousePos[2])
		end})
	end
end

function self.Initialize(parentWorld)
	world = parentWorld
	self.animDt = 0
end

return self