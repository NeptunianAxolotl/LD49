
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
		soundFirst = "rope_grab",
		soundSecond = "rope_letgo",
	},
	chain = {
		shopImage = "chain_powerup",
		gameImage = "chain_strand",
		strength = 2.8,
		restore = 0.04,
		maxStretch = 1.5,
		soundFirst = "chain_grab",
		soundSecond = "chain_letgo",
	},
	nano = {
		shopImage = "nano_powerup",
		gameImage = "nano_strand",
		strength = 15,
		restore = 0.04,
		maxStretch = 0.8,
		setDistance = true,
		soundFirst = "nano_grab",
		soundSecond = "nano_letgo",
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
	local powerupData = powerupDefs[self.currentPowerup]
	if self.firstClicked and self.firstClicked.dead then
		self.firstClicked = false
	end
	if not self.firstClicked then
		self.firstClicked = component
		self.firstClickedPos = component.WorldToLocal({x, y})
		SoundHandler.PlaySound(powerupData.soundFirst)
		self.selectSoundBlocked = 0.4
		return
	end
	if self.firstClicked.index == component.index then
		return
	end
	SoundHandler.PlaySound(powerupData.soundSecond)
	self.selectSoundBlocked = 0.4
	
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
	SoundHandler.PlaySound("obj_grab")
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
	drawQueue:push({y=Global.PIECE_DRAW_ORDER_SHOP; f=function()
		Resources.DrawImage(powerupDefs[powerupType].shopImage, pos[1], pos[2], self.animDt)
	end})
end

function api.AllowSelectSound()
	return not self.selectSoundBlocked
end

--------------------------------------------------
-- Updating
--------------------------------------------------

function api.Update(dt)
	self.animDt = self.animDt + dt
	if self.selectSoundBlocked then
		self.selectSoundBlocked = self.selectSoundBlocked - dt
		if self.selectSoundBlocked < 0 then
			self.selectSoundBlocked = false
		end
	end
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
