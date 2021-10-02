
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
	love.physics.newRopeJoint(firstClicked.body, component.body, firstPos[1], firstPos[2], x, y, util.Dist(firstPos, {x, y}))
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

end

function self.Initialize(parentWorld)
	world = parentWorld
	self.animDt = 0
end

return self