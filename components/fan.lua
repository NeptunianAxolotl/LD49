local util = require("include/util")

return {
	density = 1.5 * Global.DENSITY_MULT,
	maxNumberOfVertices = 8,
	minSize = 80,
	maxSize = 100,
	foregroundImage = "wind2",
	backgroundImage = "wind",
	borderImage = "wind",
	borderThickness = 40,
	animSpeed = 10,
	windBoost = 3,
	seaDamage = 0.1 * Global.SEA_DAMAGE_MULT,
}
