
local util = require("include/util")

local techProgression = {
	{
		cost = 20,
		newCards = {
			"nuclear_generator",
			"fuelcell",
		},
		shuffleDeck = true,
		message = "unlock_slot_2",
		drawSize = 2,
	},
	{
		cost = 80,
		newCards = {
			"solar",
			"rope",
			"solar",
		},
		jumpToEnd = true,
		message = "unlock_solar",
	},
	{
		cost = 100,
		newCards = {
			"solar",
			"research",
			"rope",
			"office"
		},
		jumpToEnd = true,
		message = "unlock_office",
	},
	{
		cost = 200,
		drawSize = 3,
		message = "unlock_slot_3"
	},

}

local costMult = 1.4
local baseCost = 100
for i = 1, #techProgression do
	if not techProgression[i].cost then
		techProgression[i].cost = math.floor(baseCost*math.pow(costMult, i)/10)*10
	end
end

local function GetTech(level)
	if not techProgression[level] then
		techProgression[level] = util.CopyTable(techProgression[level - 1])
		techProgression[level].cost = techProgression[level].cost*costMult
	end
	return techProgression[level]
end

local funcs = {
	GetTech = GetTech,
}

return funcs
