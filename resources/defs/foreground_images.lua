local defs = {
	{
		name = "solar_icon",
	},
	{
		name = "wind_icon",
		xScale = 0.43,
		yScale = 0.43,
	},
	{
		name = "office_icon",
	},
	{
		name = "research_icon",
		xScale = 0.18,
		yScale = 0.18,
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
	defs[i].xScale = defs[i].xScale or 0.25
	defs[i].yScale = defs[i].yScale or 0.25
	defs[i].xOffset = 0.5
	defs[i].yOffset = 0.5
	defs[i].file = "resources/images/polygonIcons/" .. defs[i].name .. ".png"
end

return defs