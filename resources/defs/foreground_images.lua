local defs = {
	{
		name = "solar_icon",
	},
	{
		name = "wind_icon",
	},
	{
		name = "office_icon",
	},
	{
		name = "research_icon",
	},
	{
		name = "marine_icon",
	},
	{
		name = "generator_icon",
	},
	{
		name = "fuelcell_icon",
	},
}

for i = 1, #defs do
	defs[i].form = "image" -- image, sound or animation
	defs[i].xScale = 0.25
	defs[i].yScale = 0.25
	defs[i].xOffset = 0
	defs[i].yOffset = 0
	defs[i].file = "resources/images/polygonIcons/" .. defs[i].name .. ".png"
end

return defs