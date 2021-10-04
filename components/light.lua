local util = require("include/util")

return {
	density = 0.5 * Global.DENSITY_MULT,
	maxNumberOfVertices = 8,
	minSize = 80,
	maxSize = 100,
	foregroundImage = "light_icon",
	backgroundImage = "solar",
	borderImage = "wind",
	borderThickness = 40,
	solarBoost = 2,
	seaDamage = 0.1 * Global.SEA_DAMAGE_MULT,
}
