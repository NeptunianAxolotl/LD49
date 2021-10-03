
local techProgression = {
	{
		cost = 40,
		newCards = {
			"solar",
			"wind",
			"solar",
			"research",
		},
	},
	{
		cost = 40,
		newCards = {
			"rope",
			"fuelcell",
			"wind",
		},
	},
	{
		cost = 120,
		newCards = {
			"solar",
			"wind",
			"fuelcell",
		},
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
