
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

function self.AddSeaDamage(damage)
	self.seaDamage = self.seaDamage + damage
end

function self.SetResearchRate(newRate)
	newRate = math.floor(math.pow(newRate, 0.75))/100
	self.researchRate = newRate
end

function self.DoResearchTurn(damage)
	self.SetResearchRate(ComponentHandler.GetResearchRate())
	self.researchProgress = self.researchProgress + self.researchRate
end

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
	
	love.graphics.setColor(1, 1, 1, 1)
	Font.SetSize(0)
	love.graphics.printf(math.floor(self.seaDamage*100) .. "%", drawPos[1] + 345, drawPos[2] - 45, 300, "left")
	love.graphics.setColor(1, 1, 1, 1)
	
	love.graphics.setColor(1, 1, 1, 1)
	Font.SetSize(0)
	love.graphics.printf("Research Progress: " .. math.floor(self.researchProgress*100) .. "%", drawPos[1] + 45, drawPos[2] - 245, 500, "left")
	love.graphics.printf("Research Rate: " .. math.floor(self.researchRate*100) .. "%", drawPos[1] + 45, drawPos[2] - 200, 500, "left")
	love.graphics.setColor(1, 1, 1, 1)
	
	drawPos = world.ScreenToInterface({windowX, 0})
	Resources.DrawImage("menu_button", drawPos[1], math.ceil(drawPos[2]))
end

function self.Initialize(parentWorld)
	world = parentWorld
	self.seaDamage = 0
	self.researchRate = 0
	self.researchProgress = 0
end

return self