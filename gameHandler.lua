
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

--------------------------------------------------
-- Updating
--------------------------------------------------

local botOffset = 0
local elWidth = 196
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
	sea = {0, 1},
	bank = {0, 1},
}

local posStart = {
	energy = {-botOffset, 200},
	demand = {elWidth - botOffset, 200},
	admin = {2*elWidth - botOffset, 200},
	research = {0, -200},
	score = {0, -200},
	sea = {-250, 200},
	bank = {-250, 200}
}

local posEnd = {
	energy = {-botOffset, 0},
	demand = {elWidth - botOffset, 0},
	admin = {2*elWidth - botOffset, 0},
	research = {0, 0},
	score = {0, 200},
	sea = {0, 200},
	sea = {0, 200},
}

local textOffset = {
	energy = {60, -45},
	demand = {70, -45},
	admin = {60, -45},
	research = {370, 13},
	score = {0, -200},
	sea = {-200, 200},
	bank = {-200, 200}
}

local barFunc = {
	research = function ()
		local col = {0, 1, 1, 1}
		local prop = GetNumber("research")
		local text = Round(GetNumber("research")*DeckHandler.GetResearchCost()) .. " / " .. Round(DeckHandler.GetResearchCost())
		local pos, size = {58, 9}, {300, 40}
		return col, prop, text, pos, size
	end,
}

local background = {
	energy = "interface",
	demand = "interface",
	admin = "interface",
	research = "interface_flip_big",
	score = "interface",
	sea = "interface_big",
	bank = "interface_big",
}

local icon = {
	energy = "energy_icon",
	demand = "demand_icon",
	admin = "admin_icon",
	research = "science_icon",
	score = "science_icon",
	sea = "science_icon",
	bank = "science_icon",
}

local iconOffset = {
	energy = {28 + botOffset, -30},
	demand = {40 + botOffset, -30},
	admin = {40 + botOffset, -30},
	research = {30, 30},
	score = {30, 30},
	sea = {30, 30},
	bank = {30, 30},
}

local getItemValue = {
	energy = function () return math.floor(ComponentHandler.GetEnergy()*self.GetPostPowerMult()), ComponentHandler.GetEnergy() > 0 end,
	demand = function () return self.energyDemand, self.energyDemand > 0 end,
	admin = function ()
		return "+" .. Round(100*(self.GetPostPowerMult() - 1)) .. "%", self.GetPostPowerMult() > 1
	end,
	research = function ()
		return "+" .. (self.researchRate * DeckHandler.GetResearchCost()), self.researchRate > 0
	end,
	score = function () return false, false end,
	sea = function () return false, false end,
	bank = function () return false, false end,
}

local function GetItemPos(itemName, windowY)
	local shown = self.itemShown[itemName]
	if shown <= 0 then
		return false
	end
	local prop = util.SmoothZeroToOne(shown, 6)
	print(prop)
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
	local textPos = util.Add(textOffset[itemName], pos)
	
	Resources.DrawImage(background[itemName], math.ceil(pos[1]), math.ceil(pos[2]))
	love.graphics.setColor(1, 1, 1, 1)
	Font.SetSize(0)
	love.graphics.printf(value, textPos[1], textPos[2], 300, "left")
	
	local iconPos = util.Add(iconOffset[itemName], pos)
	Resources.DrawImage(icon[itemName], math.ceil(iconPos[1]), math.ceil(iconPos[2]))
	
	if barFunc[itemName] then
		local col, prop, text, barPos, barSize = barFunc[itemName]()
		barPos = util.Add(pos, barPos)
		
		love.graphics.setColor(barCol, barCol, barCol, 1)
		love.graphics.rectangle("fill", barPos[1], barPos[2], barSize[1], barSize[2])
		
		love.graphics.setColor(col[1], col[2], col[3], 1)
		love.graphics.rectangle("fill", barPos[1], barPos[2], barSize[1]*prop, barSize[2])
		
		local barMid = util.Add(barPos, util.Mult(0.5, barSize))
		love.graphics.setColor(1, 1, 1, 1)
		Font.SetSize(0)
		love.graphics.printf(text, barPos[1], textPos[2], barSize[1], "center")
	end
	
	love.graphics.setColor(1, 1, 1, 1)
end

--------------------------------------------------
-- API
--------------------------------------------------

local function UpdateEnergyDemand()
	if self.turn < 10 then
		return
	end
	if self.energyDemand == 0 then
		self.energyDemand = 300
	end
	self.energyDemand = self.energyDemand + 30 + math.floor(self.turn/10)*10
end

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
	if true then return 10 end
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
end

function self.DrawInterface()
	local windowX, windowY = love.window.getMode()
	
	for i = 1, #itemList do
		DrawItem(itemList[i], windowY)
	end
	
	--Resources.DrawImage("interface", drawPos[1], math.ceil(drawPos[2]))
	--
	--local totalEnergy = math.floor(ComponentHandler.GetEnergy()*self.GetPostPowerMult())
	--
	--love.graphics.setColor(1, 1, 1, 1)
	--Font.SetSize(0)
	--love.graphics.printf(totalEnergy, drawPos[1] + 45, drawPos[2] - 45, 300, "left")
	--love.graphics.setColor(1, 1, 1, 1)
	--
	--love.graphics.setColor(1, 1, 1, 1)
	--Font.SetSize(0)
	--love.graphics.printf(math.floor(self.seaDamage*100) .. "%", drawPos[1] + 345, drawPos[2] - 45, 300, "left")
	--love.graphics.setColor(1, 1, 1, 1)
	--
	--love.graphics.setColor(1, 1, 1, 1)
	--Font.SetSize(0)
	--love.graphics.printf("Research Progress: " .. math.floor(self.researchProgress*100) .. "%", drawPos[1] + 45, drawPos[2] - 245, 500, "left")
	--love.graphics.printf("Research Rate: " .. math.floor(self.researchRate*100) .. "%", drawPos[1] + 45, drawPos[2] - 200, 500, "left")
	--love.graphics.setColor(1, 1, 1, 1)
	--
	--love.graphics.setColor(1, 1, 1, 1)
	--Font.SetSize(0)
	--love.graphics.printf("Admin bonus: " .. math.floor(100*(self.GetPostPowerMult() - 1)) .. "%", drawPos[1] + 45, drawPos[2] - 160, 500, "left")
	--love.graphics.setColor(1, 1, 1, 1)
	--
	--love.graphics.setColor(1, 1, 1, 1)
	--Font.SetSize(0)
	--love.graphics.printf("Turn: " .. self.turn, drawPos[1] + 45, drawPos[2] - 800, 500, "left")
	--love.graphics.setColor(1, 1, 1, 1)
	--
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
	self.energyDemand = 10
	
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