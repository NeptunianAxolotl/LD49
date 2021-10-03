
local util = require("include/util")
local Font = require("include/font")

local EffectsHandler = require("effectsHandler")
local ComponentHandler = require("componentHandler")
local Resources = require("resourceHandler")

local self = {}
local world

--------------------------------------------------
-- API
--------------------------------------------------

--------------------------------------------------
-- Updating
--------------------------------------------------

function self.Update(dt)
end

function self.DrawInterface()
	local windowX, windowY = love.window.getMode()
	local drawPos = world.ScreenToInterface({0, windowY})
	Resources.DrawImage("main_ui", drawPos[1], math.ceil(drawPos[2]))
	
	local totalEnergy = ComponentHandler.GetEnergy()
	
	love.graphics.setColor(1, 1, 1, 1)
	Font.SetSize(0)
	love.graphics.printf(totalEnergy, drawPos[1] + 45, drawPos[2] - 45, 300, "left")
	love.graphics.setColor(1, 1, 1, 1)
	
	
	drawPos = world.ScreenToInterface({windowX, 0})
	Resources.DrawImage("menu_button", drawPos[1], math.ceil(drawPos[2]))
	
end

function self.Initialize(parentWorld)
	world = parentWorld
end

return self