
local util = require("include/util")

local EffectsHandler = require("effectsHandler")
local ComponentHandler = require("componentHandler")
local PowerupHandler = require("powerupHandler")

local techProgression = require("defs/techProgression")

local self = {}
local world

local initialDeck = {
	"nuclear_generator",
	"fuelcell",
	"research",
	"wind",
}

local function GetDrawSize()
	if GameHandler.GetTurn() <= 3 then
		return 1
	end
	return self.drawSize
end

local function DrawCard()
	if not self.deck[self.drawIndex] then
		if self.currentTech == 1 then
			return (math.random() < 0.5 and "wind") or "research"
		end
		util.Permute(self.deck)
		self.drawIndex = 1
	end
	local draw = self.deck[self.drawIndex]
	self.drawIndex = self.drawIndex + 1
	return draw
end

--------------------------------------------------
-- API
--------------------------------------------------

function self.TechUp()
	local tech = techProgression.GetTech(self.currentTech)
	if tech.newCards then
		for i = 1, #tech.newCards do
			print("adding", tech.newCards[i])
			self.deck[#self.deck + 1] = tech.newCards[i]
		end
	end
	if tech.jumpToEnd then
		self.drawIndex = #self.deck
	end
	if tech.shuffleDeck then
		util.Permute(self.deck)
	end
	if tech.drawSize then
		self.drawSize = tech.drawSize
	end
	
	self.currentTech = self.currentTech + 1
	self.nextTechCost = techProgression.GetTech(self.currentTech).cost
end

function self.GetResearchCost()
	return self.nextTechCost
end

function self.GetNextDraw()
	local drawCount = GetDrawSize()
	local toDraw = {}
	local drawnType = {}
	local tries = 10
	while #toDraw < drawCount and tries > 0 do
		local card = DrawCard()
		if not drawnType[card] then
			toDraw[#toDraw + 1] = card
			drawnType[card] = true
		end
		tries = tries - 1
	end
	
	return toDraw
end

--------------------------------------------------
-- Updating
--------------------------------------------------

function self.Initialize(parentWorld)
	world = parentWorld
	self.deck = util.CopyTable(initialDeck)
	self.drawIndex = 1
	self.drawSize = 2
	self.currentTech = 1
	self.nextTechCost = techProgression.GetTech(self.currentTech).cost
end

return self