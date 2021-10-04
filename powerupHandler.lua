
local util = require("include/util")

local EffectsHandler = require("effectsHandler")
local ComponentHandler = require("componentHandler")
local Resources = require("resourceHandler")

local self = {}
local world

local powerupList = {
	"rope",
	"chain",
}

local powerupDefs = {
	rope = {
		shopImage = "rope_powerup",
		gameImage = "rope_strand",
		strength = 1.1,
		restore = 0.02,
		maxStretch = 2,
	},
	chain = {
		shopImage = "chain_powerup",
		gameImage = "chain_strand",
		strength = 2.2,
		restore = 0.04,
		maxStretch = 1.5,
	},
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
	
	local powerupData = powerupDefs[currentPowerup]
	
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
		strength = powerupData.strength,
		maxStretch = powerupData.maxStretch,
		restore = powerupData.restore,
		image = powerupData.gameImage,
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

function self.IsPowerup(powerupType)
	return powerupDefs[powerupType]
end

function self.MousePressed(x, y)
	DoPowerupMouseAction(x, y)
end

function self.MouseReleased(x, y)
	DoPowerupMouseAction(x, y)
end

function self.DrawPowerup(drawQueue, powerupType, pos)
	drawQueue:push({y=0; f=function()
		Resources.DrawImage(powerupDefs[powerupType].shopImage, pos[1], pos[2], self.animDt)
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
		drawQueue:push({y=Global.WORLD_MOUSE_DRAW_ORDER; 
		f=function()
			local firstPos = firstClicked.LocalToWorld(firstClickedPos)
			local mousePos = world.GetMousePosition()
			local linkVector = util.Subtract(mousePos, firstPos)
			
			Resources.DrawImage(powerupDefs[currentPowerup].gameImage, firstPos[1], firstPos[2], util.Angle(linkVector), 1, {util.AbsVal(linkVector)/300, 1})
		end})
	end
end

function self.DrawInterface()
	if currentPowerup then
		local pos = world.GetMousePositionInterface()
		local angle = math.sin(self.animDt*15)*0.2
		Resources.DrawImage(powerupDefs[currentPowerup].shopImage, pos[1], pos[2], angle, 1, 0.5)
	end
end


function self.Initialize(parentWorld)
	world = parentWorld
	self.animDt = 0
end

return self