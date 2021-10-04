
local chatProgression = {
	onTurn = {
		[1] = {
			text = {"Click and drag the windmill onto island to start making power."},
			delay = 0,
		},
		[3] = {
			text = {"Put the fuel cell near the rector to give it energy."},
			delay = 1.5,
		},
		[5] = {
			text = {"Add a research lab to unlock more and better tech.", "Don't put those scientists too close to the fuel cell!"},
			delay = 1.5,
		},
	},
	unlock_solar = {
		text = {"Scientists have unlocked solar technlology."},
	},
	unlock_rope = {
		text = {"Scientists have unlocked rope to tie things together."},
	},
}


return chatProgression
