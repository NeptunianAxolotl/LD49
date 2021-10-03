
local util = require("include/util")

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
	
	drawPos = world.ScreenToInterface({windowX, 0})
	Resources.DrawImage("menu_button", drawPos[1], math.ceil(drawPos[2]))
end

function self.Initialize(parentWorld)
	world = parentWorld
end

return self