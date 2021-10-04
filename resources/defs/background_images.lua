local defs = {
	{
		name = "solar",
	},
	{
		name = "wind",
	},
	{
		name = "office",
	},
	{
		name = "research",
	},
	{
		name = "marine",
	},
	{
		name = "nuclear",
	},
	{
		name = "office2",
	},
	{
		name = "research2",
	},
}

for i = 1, #defs do
	defs[i].form = "image" -- image, sound or animation
	defs[i].xScale = 0.25
	defs[i].yScale = 0.25
	defs[i].xOffset = 0
	defs[i].yOffset = 0
	defs[i].file = "resources/images/polygonTextures/" .. defs[i].name .. ".png"
end

return defs