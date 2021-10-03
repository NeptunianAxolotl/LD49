
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

function self.UpdateRates(research, popCost, popRoom)
	self.researchRate = research/DeckHandler.GetResearchCost()
	self.adminRequired = popCost
	self.adminSupplied = popRoom
end

function self.DoTurn()
	self.turn = self.turn + 1
	self.researchProgress = self.researchProgress + ComponentHandler.GetResearchRate()/DeckHandler.GetResearchCost()
	if self.researchProgress >= 1 then
		self.researchProgress = 0
		DeckHandler.TechUp()
	end
end

function self.GetWorkEfficiency()
	if self.adminSupplied <= 1 then
		return 1
	end
	if self.adminRequired <= 1 then
		return 1
	end
	return 1
end

function self.GetTurn()
	return self.turn
end

function self.GetPostPowerMult()
	if self.adminSupplied <= 1 then
		return 1
	end
	if self.adminRequired <= 1 then
		return 1
	end
	return 1 + self.adminSupplied*0.0025
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
	
	local totalEnergy = math.floor(ComponentHandler.GetEnergy()*self.GetPostPowerMult())
	
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
	
	love.graphics.setColor(1, 1, 1, 1)
	Font.SetSize(0)
	love.graphics.printf("Admin bonus: " .. math.floor(100*(self.GetPostPowerMult() - 1)) .. "%", drawPos[1] + 45, drawPos[2] - 160, 500, "left")
	love.graphics.setColor(1, 1, 1, 1)
	
	love.graphics.setColor(1, 1, 1, 1)
	Font.SetSize(0)
	love.graphics.printf("Turn: " .. self.turn, drawPos[1] + 45, drawPos[2] - 800, 500, "left")
	love.graphics.setColor(1, 1, 1, 1)
	
	drawPos = world.ScreenToInterface({windowX, 0})
	Resources.DrawImage("menu_button", drawPos[1], math.ceil(drawPos[2]))
end

function self.Initialize(parentWorld)
	world = parentWorld
	self.seaDamage = 0
	self.researchRate = 0
	self.researchProgress = 0
	self.researchCost = 1
	self.adminRequired = 0
	self.adminSupplied = 0
	self.turn = 0
end

return self