
local techProgression = {
	{
		cost = 50,
		newCards = {
			"solar",
			"wind",
			"solar",
		},
		jumpToEnd = true,
	},
	{
		cost = 120,
		newCards = {
			"fuelcell",
			"wind",
			"rope",
		},
		jumpToEnd = true,
	},
	{
		cost = 240,
		newCards = {
			"solar",
			"research",
			"fuelcell",
			"wind",
			"nuclear_generator",
			"rope",
		},
		shuffleDeck = true,
	},
	{
		cost = 600,
		newCards = {
			"office",
			"research",
		},
	},

}

local costMult = 1.4
local baseCost = 100
for i = 1, #techProgression do
	if not techProgression[i].cost then
		techProgression[i].cost = baseCost*math.pow(costMult, i)
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
