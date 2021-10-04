
local util = require("include/util")

local EffectsHandler = require("effectsHandler")
local ComponentHandler = require("componentHandler")
local Resources = require("resourceHandler")

local api = {}
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
		strength = 1.5,
		restore = 0.02,
		maxStretch = 2,
	},
	chain = {
		shopImage = "chain_powerup",
		gameImage = "chain_strand",
		strength = 4,
		restore = 0.04,
		maxStretch = 1.5,
	},
}

--------------------------------------------------
-- API
--------------------------------------------------

local function DoPowerupMouseAction(x, y)
	if not self.currentPowerup then
		return
	end
	local component = ComponentHandler.GetComponentAt(x, y, true)
	if not component then
		return
	end
	if self.firstClicked and self.firstClicked.dead then
		firstClicked = false
	end
	if not self.firstClicked then
		self.firstClicked = component
		self.firstClickedPos = component.WorldToLocal({x, y})
		return
	end
	if self.firstClicked.index == component.index then
		return
	end
	
	local powerupData = powerupDefs[self.currentPowerup]
	
	local firstPos = self.firstClicked.LocalToWorld(self.firstClickedPos)
	local ropeLength = util.Dist(firstPos, {x, y})
	local joint = love.physics.newRopeJoint(self.firstClicked.body, component.body, firstPos[1], firstPos[2], x, y, ropeLength, true)
	
	self.firstClicked.jointData = self.firstClicked.jointData or {}
	self.firstClicked.jointData[#self.firstClicked.jointData + 1] = {
		joint = joint,
		desiredLength = ropeLength,
		startPos = self.firstClickedPos,
		endComponent = component,
		endPos = component.WorldToLocal({x, y}),
		strength = powerupData.strength,
		maxStretch = powerupData.maxStretch,
		restore = powerupData.restore,
		image = powerupData.gameImage,
	}
	
	self.currentPowerup = false
	self.firstClicked = false
	self.firstClickedPos = false
end

--------------------------------------------------
-- API
--------------------------------------------------

function api.GetRandomPowerup()
	return util.SampleList(powerupList)
end

function api.SelectPowerup(powerupType)
	self.currentPowerup = powerupType
end

function api.IsPowerup(powerupType)
	return powerupDefs[powerupType]
end

function api.MousePressed(x, y)
	DoPowerupMouseAction(x, y)
end

function api.MouseReleased(x, y)
	DoPowerupMouseAction(x, y)
end

function api.DrawPowerup(drawQueue, powerupType, pos)
	drawQueue:push({y=0; f=function()
		Resources.DrawImage(powerupDefs[powerupType].shopImage, pos[1], pos[2], self.animDt)
	end})
end

--------------------------------------------------
-- Updating
--------------------------------------------------

function api.Update(dt)
	self.animDt = self.animDt + dt
end

function api.Draw(drawQueue)
	if self.firstClicked and not self.firstClicked.dead then
		drawQueue:push({y=Global.WORLD_MOUSE_DRAW_ORDER; 
		f=function()
			local firstPos = self.firstClicked.LocalToWorld(self.firstClickedPos)
			local mousePos = world.GetMousePosition()
			local linkVector = util.Subtract(mousePos, firstPos)
			
			Resources.DrawImage(powerupDefs[self.currentPowerup].gameImage, firstPos[1], firstPos[2], util.Angle(linkVector), 1, {util.AbsVal(linkVector)/300, 1})
		end})
	end
end

function api.DrawInterface()
	if self.currentPowerup then
		local pos = world.GetMousePositionInterface()
		local angle = math.sin(self.animDt*15)*0.2
		Resources.DrawImage(powerupDefs[self.currentPowerup].shopImage, pos[1], pos[2], angle, 1, 0.5)
	end
end


function api.Initialize(parentWorld)
	self = {}
	world = parentWorld
	self.animDt = 0
end

return api
