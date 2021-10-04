
local util = require("include/util")
local Font = require("include/font")

local EffectsHandler = require("effectsHandler")
local ComponentHandler = require("componentHandler")
local Resources = require("resourceHandler")

local self = {}
local world

--------------------------------------------------
-- Updating
--------------------------------------------------

local function Round(x)
	return math.floor(x + 0.5)
end


local smoothNumberList = {
	{
		name = "research",
		wrap = 1,
	},
	{
		name = "sea",
	},
	{
		name = "bank",
	},
	{
		name = "score",
	},
}


local function UpdateSmoothNumber(dt, name)
	local number = self.smoothNumbers[name]
	if not number.diff or number.diff == 0 then
		return
	end
	local rate = (0.04 + 0.05 * math.abs(number.want - number.has) / number.diff)
	if math.abs(rate) <= 0.042 then
		number.has = number.want
		number.diff = false
	end
	number.has = number.has + rate*(number.want - number.has)
end

local function SetNumber(name, value)
	local number = self.smoothNumbers[name]
	while number.wrap and value < number.want do
		value = value + 1
	end
	number.want = value
	number.diff = math.abs(number.want - number.has)
end

local function GetNumber(name)
	local number = self.smoothNumbers[name]
	if number.wrap then
		return number.has%number.wrap
	end
	return number.has
end

local function GetBarProp(prop)
	local period = math.max(0.25, 1 - 0.8*prop)
	local amount = self.barDt%period
	if amount > period*0.5 then
		return util.SmoothZeroToOne(2*(1 - amount/period), 3)
	else
		return util.SmoothZeroToOne(2*amount/period, 3)
	end
end

--------------------------------------------------
-- Updating
--------------------------------------------------

local botOffset = 0
local elWidth = 202
local showSpeed = 0.5
local barCol = 0.4

local itemList = {
	"score",
	"research",
	"sea",
	"bank",
	"admin",
	"demand",
	"energy",
}

local sticky = {
	energy = true,
	demand = true,
	admin = true,
	research = true,
	score = true,
	sea = false,
	bank = false,
}

local itemOrigin = {
	energy = {0, 1},
	demand = {0, 1},
	admin = {0, 1},
	research = {0, 0},
	score = {0, 0},
	sea = {0, 0.333},
	bank = {0, 0.666},
}

local posStart = {
	energy = {-botOffset, 100},
	demand = {elWidth - botOffset, 100},
	admin = {2*elWidth - botOffset, 100},
	research = {0, -100},
	score = {0, -100},
	sea = {-100, 0},
	bank = {-100, 0},
}

local posEnd = {
	energy = {-botOffset, 0},
	demand = {elWidth - botOffset, 0},
	admin = {2*elWidth - botOffset, 0},
	research = {0, 0},
	score = {0, 56},
	sea = {0, 0},
	bank = {0, 0},
}

local textOffset = {
	energy = {60, -45},
	demand = {73, -45},
	admin = {60, -45},
	research = {370, 13},
	score = {20, 13},
	sea = {15, 13},
	bank = {15, 13},
}

local barFunc = {
	research = function ()
		local col = {0, 1, 1, 1}
		local prop = GetNumber("research")
		local text = Round(GetNumber("research")*DeckHandler.GetResearchCost()) .. " / " .. Round(DeckHandler.GetResearchCost())
		local pos, size = {58, 9}, {300, 40}
		return col, prop, text, pos, size
	end,
	sea = function ()
		local prop = GetNumber("sea")
		local barProp = GetBarProp(prop)
		local col = {1, 0.8*barProp*prop, 0, 1}
		local text = Round(GetNumber("sea")*100) .. "%"
		local pos, size = {8, -125}, {40, 220}
		return col, prop, text, pos, size
	end,
	bank = function ()
		local prop = GetNumber("bank")
		local barProp = GetBarProp(prop)
		local col = {1, 0.8*barProp*prop, 0, 1}
		local text = Round(GetNumber("bank")*100) .. "%"
		local pos, size = {8, -125}, {40, 220}
		return col, prop, text, pos, size
	end,
}

local background = {
	energy = "interface",
	demand = "interface",
	admin = "interface",
	research = "interface_flip_big",
	score = "interface_flip",
	sea = "interface_rot",
	bank = "interface_rot",
}

local icon = {
	energy = "energy_icon",
	demand = "demand_icon",
	admin = "admin_icon",
	research = "science_icon",
	score = false,
	sea = "sea_icon",
	bank = "bank_icon",
}

local iconOffset = {
	energy = {28 + botOffset, -30},
	demand = {44 + botOffset, -30},
	admin = {40 + botOffset, -30},
	research = {30, 30},
	score = {30, 30},
	sea = {28, 118},
	bank = {28, 118},
}

local getItemValue = {
	energy = function () return Round(ComponentHandler.GetEnergy()*self.GetPostPowerMult()), ComponentHandler.GetEnergy() > 0 end,
	demand = function () return self.energyDemand, self.energyDemand > 0 end,
	admin = function ()
		return "+" .. Round(100*(self.GetPostPowerMult() - 1)) .. "%", self.GetPostPowerMult() > 1
	end,
	research = function ()
		return "+" .. (self.researchRate * DeckHandler.GetResearchCost()), self.researchRate > 0
	end,
	score = function ()
		return ("Score: " .. Round(GetNumber("score"))), (self.turn > Global.SCORE_DISPLAY_TURN)
	end,
	sea = function ()
		return "", self.seaDamage > 0
	end,
	bank = function () return "", self.bankDeath > 0 end,
}

local function GetItemPos(itemName, windowY)
	local shown = self.itemShown[itemName]
	if shown <= 0 then
		return false
	end
	local prop = util.SmoothZeroToOne(shown, 6)
	local origin = world.ScreenToInterface({0, itemOrigin[itemName][2]*windowY})
	return util.Add(origin, util.Average(posStart[itemName], posEnd[itemName], prop))
end

local function UpdateItemShow(dt, itemName)
	local value, wantShow = getItemValue[itemName]()
	if not wantShow then
		if self.itemShown[itemName] == 0 then
			return
		elseif self.itemShown[itemName] > 0 and not sticky[itemName] then
			self.itemShown[itemName] = math.max(0, self.itemShown[itemName] - dt*showSpeed)
			return
		end
	end
	if self.itemShown[itemName] < 1 then
		self.itemShown[itemName] = math.min(1, self.itemShown[itemName] + dt*showSpeed)
	end
end

local function DrawItem(itemName, windowY)
	local pos = GetItemPos(itemName, windowY)
	if not pos then
		return
	end
	local value = getItemValue[itemName]()
	
	Resources.DrawImage(background[itemName], math.ceil(pos[1]), math.ceil(pos[2]))
	love.graphics.setColor(1, 1, 1, 1)
	
	local textPos = util.Add(textOffset[itemName], pos)
	Font.SetSize(0)
	love.graphics.printf(value, textPos[1], textPos[2], 300, "left")
	
	if icon[itemName] then
		local iconPos = util.Add(iconOffset[itemName], pos)
		Resources.DrawImage(icon[itemName], math.ceil(iconPos[1]), math.ceil(iconPos[2]))
	end

	if barFunc[itemName] then
		local col, prop, text, barPos, barSize = barFunc[itemName]()
		prop = math.max(0, math.min(1, prop))
		barPos = util.Add(pos, barPos)
		
		love.graphics.setColor(barCol, barCol, barCol, 1)
		love.graphics.rectangle("fill", barPos[1], barPos[2], barSize[1], barSize[2])
		
		love.graphics.setColor(col[1], col[2], col[3], 1)
		if barSize[1] > barSize[2] then
			love.graphics.rectangle("fill", barPos[1], barPos[2], barSize[1]*prop, barSize[2])
			Font.SetSize(0)
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.printf(text, barPos[1], textPos[2], barSize[1], "center")
		else
			love.graphics.rectangle("fill", barPos[1], barPos[2] + barSize[2]*(1 - prop), barSize[1], barSize[2]*prop)
			Font.SetSize(0)
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.printf(text, textPos[1], barPos[2] + barSize[2], barSize[2], "center", -math.pi/2)
		end
		
	end
	
	love.graphics.setColor(1, 1, 1, 1)
end

--------------------------------------------------
-- API
--------------------------------------------------

local function UpdateEnergyAndDemand()
	local energy = Round(ComponentHandler.GetEnergy()*self.GetPostPowerMult())
	self.score = self.score + energy
	
	if energy < self.energyDemand then
		local mult = (self.bankDeath == 0 and 1.5) or 1
		self.bankDeath = self.bankDeath + (0.1 + math.min(0.15, 0.1*self.energyDemand / energy))*mult
	elseif self.bankDeath > 0 then
		self.bankDeath = math.max(0, self.bankDeath - 0.25)
	end
	
	SetNumber("bank", self.bankDeath)
	SetNumber("score", self.score)
end

local function UpdateSeaHealth()

end

local function UpdateEnergyDemand()
	if self.turn < 15 then
		return
	end
	if self.energyDemand == 0 then
		self.energyDemand = 300
	elseif self.turn%5 == 0 then
		self.energyDemand = self.energyDemand + 100 + math.floor(self.turn/15)*50
	end
end

--------------------------------------------------
-- API
--------------------------------------------------

function self.AddSeaDamage(damage)
	self.seaDamage = self.seaDamage + damage
	SetNumber("sea", self.seaDamage)
end

function self.UpdateRates(research, popCost, popRoom)
	self.researchRate = research/DeckHandler.GetResearchCost()
	self.adminRequired = popCost
	self.adminSupplied = popRoom
end

function self.DoTurn()
	ComponentHandler.RecalcEffects()
	self.turn = self.turn + 1
	ChatHandler.ChatTurn(self.turn)
	self.researchProgress = self.researchProgress + ComponentHandler.GetResearchRate()/DeckHandler.GetResearchCost()
	if self.researchProgress >= 1 then
		local leftOver = (self.researchProgress - 1)*DeckHandler.GetResearchCost()
		DeckHandler.TechUp()
		self.researchProgress = leftOver/DeckHandler.GetResearchCost()
		self.researchRate = ComponentHandler.GetResearchRate()/DeckHandler.GetResearchCost()
	end
	SetNumber("research", self.researchProgress)

	UpdateEnergyAndDemand()
	UpdateSeaHealth()
	UpdateEnergyDemand()
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
	for i = 1, #itemList do
		UpdateItemShow(dt, itemList[i])
	end
	for i = 1, #smoothNumberList do
		UpdateSmoothNumber(dt, smoothNumberList[i].name)
	end
	self.barDt = self.barDt + dt
end

function self.DrawInterface()
	local windowX, windowY = love.window.getMode()
	
	for i = 1, #itemList do
		DrawItem(itemList[i], windowY)
	end
	
	--drawPos = world.ScreenToInterface({windowX, 0})
	--Resources.DrawImage("menu_button", drawPos[1], math.ceil(drawPos[2]))
end

function self.Initialize(parentWorld)
	world = parentWorld
	self.seaDamage = 0
	self.researchRate = 0
	self.researchProgress = 0
	self.researchCost = 1
	self.adminRequired = 0
	self.adminSupplied = 0
	self.energyDemand = 0
	self.bankDeath = 0
	self.score = 0
	self.barDt = 0
	
	self.itemShown = {
		energy = 0,
		demand = 0,
		admin = 0,
		research = 0,
		score = 0,
		sea = 0,
		bank = 0,
	}
	
	self.smoothNumbers = {}
	for i = 1, #smoothNumberList do
		self.smoothNumbers[smoothNumberList[i].name] = {
			has = 0,
			want = 0,
			diff = false,
			wrap = smoothNumberList[i].wrap,
		}
	end

	self.turn = 1
	ChatHandler.ChatTurn(self.turn)
end

return self