
local util = require("include/util")

local techProgression = {
	{
		cost = 20,
		newCards = {
			"nuclear_generator",
			"fuelcell",
			"research",
		},
		shuffleDeck = true,
		message = "unlock_slot_2",
		drawSize = 2,
	},
	{
		cost = 70,
		newCards = {
			"rope",
		},
		jumpToEnd = true,
		message = "unlock_rope",
	},
	{
		cost = 120,
		newCards = {
			"solar",
			"rope",
			"solar",
		},
		jumpToEnd = true,
		message = "unlock_solar",
	},
	{
		cost = 160,
		message = "unlock_wsad"
	},
	{
		cost = 200,
		newCards = {
			"research",
			"office",
			"office"
		},
		jumpToEnd = true,
		message = "unlock_office",
	},
	{
		cost = 260,
		newCards = {
			"solar",
			"rope",
		},
		drawSize = 3,
		message = "unlock_slot_3"
	},
	{
		cost = 320,
		newCards = {
			"nuclear_generator",
			"fuelcell",
			"marine",
			"marine"
		},
		jumpToEnd = true,
		message = "unlock_marine",
	},
	{
		cost = 400,
		newCards = {
			"chain",
			"chain",
		},
		jumpToEnd = true,
		message = "unlock_chain",
	},
	{
		cost = 450,
		newCards = {
			"office",
			"research2",
			"research2",
			"research2",
		},
		removeCards = {
			"research",
			"research",
			"research",
		},
		jumpToEnd = true,
		message = "unlock_research2",
	},
	{
		cost = 750,
		newCards = {
			"solar",
			"light",
			"light",
		},
		jumpToEnd = true,
		message = "unlock_light",
	},
	{
		cost = 1200,
		newCards = {
			"fuelcell2",
			"fuelcell2",
		},
		removeCards = {
			"fuelcell",
		},
		jumpToEnd = true,
		message = "unlock_fuelcell2",
	},
	{
		cost = 1600,
		newCards = {
			"chain",
			"chain",
			"chain",
		},
		removeCards = {
			"rope",
			"rope",
			"rope",
		},
		jumpToEnd = true,
		message = "unlock_no_rope",
	},
	{
		cost = 2000,
		drawSize = 4,
		message = "unlock_slot_4",
	},
	{
		cost = 2500,
		newCards = {
			"marine",
			"wind",
			"fan",
			"fan",
		},
		jumpToEnd = true,
		message = "unlock_fan",
	},
	{
		cost = 3000,
		newCards = {
			"solar",
			"wind",
			"nuclear_generator",
			"solar",
			"nano",
			"nano",
		},
		removeCards = {
			"chain",
		},
		jumpToEnd = true,
		message = "unlock_nano",
	},
	{
		cost = 3800,
		newCards = {
			"solar",
			"wind",
			"nuclear_generator",
			"office2",
			"office2",
			"office2",
		},
		removeCards = {
			"office",
			"office",
			"office",
		},
		jumpToEnd = true,
		message = "unlock_office2",
	},
	{
		cost = 5000,
		newCards = {
			"light",
			"fan",
			"solar",
			"wind",
			"fuelcell",
			"fuelcell2",
			"nano",
			"nano",
			"nano",
		},
		removeCards = {
			"chain",
		},
		message = "unlock_more_nano",
	},
	{
		cost = 10000,
		drawSize = 5,
		message = "unlock_grant",
	},
}

local costMult = 2
for i = 1, #techProgression do
	if not techProgression[i].cost then
		techProgression[i].cost = techProgression[i - 1].cost * costMult
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
