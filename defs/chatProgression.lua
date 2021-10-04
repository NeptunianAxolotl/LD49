
local chatProgression = {
	onTurn = {
		[1] = {
			text = {" - Click and drag the windmill onto island to start making power."},
			delay = 0,
		},
		[3] = {
			text = {" - Put the fuel cell near the reactor to give it energy."},
			delay = 1.5,
		},
		[5] = {
			text = {" - Add a research lab to unlock more and better tech.", "Don't put those scientists too close to the fuel cell!"},
			delay = 1.5,
		},
        [20] = {
            text = {"Ah - by the way, here is a readout of the power you", "are generating.  Have to keep track of performance,", "after all!"}, --score
        },
	},
    seaDamage = {
        [1] = {
            text = {"You dropped pollutants in the ocean!", "...nobody seems to have noticed."},
        },
        [30] = {
            text = {"Your coffee tastes funny.", "It was made using purified and boiled seawater", "sourced locally from an ecological paradise.", "", "Weird."},
        },
        [50] = {
            text = {"Local fishermen are having unprecedented success.", "'The job is easy these days,' they say,", "'like skimming dead fish off the surface of the sea.'"},
        },
        [80] = {
            text = {"The sea looks greener than you remember."},
        },
        [100] = {
            text = {"Small boats crewed by people holding golf clubs", "have been sighted in the distance.",  "Your accountants have taken the liberty", "of calling the company lawyers in your stead.", "You have been 'strongly encouraged' to take the next", "available flight off the island, in case things", "escalate.", "", "You have lost the game.", "Press Ctrl+R to restart."},
        },
        
    bankDamage = {
        [1] = {
            text = {""},
            },
        [10] = {
            text = {""},
            },
        [20] = {
            text = {""},
            },
        [30] = {
            text = {""},
            },
        [40] = {
            text = {""},
            },
        [50] = {
            text = {""},
            },
        [60] = {
            text = {""},
            },
        [70] = {
            text = {""},
            },
        [80] = {
            text = {""},
            },
        [90] = {
            text = {""},
            },
        [100] = {
            text = {""},
            },
        },
    },
	unlock_solar = {
		text = {"The scientists have invented solar panels!  They’re", "not very efficient, but it’s not like that sunlight", "was doing anything else anyway."},
	},
    unlock_wsad = {
        text = {"The scientists have discovered an instruction manual!", "It is very dusty.  It says:", "You can rotate the blocks with", "A/D, Z/X, space, or the arrow keys.'"},
    },
    
	unlock_rope = {
		text = {"The scientists have invented rope!", "They say they plan to invent the bicycle next."},
	},
    unlock_chain = {
        text = {"The scientists have invented chain!", "Unlike rope, chain does not stretch under tension.", "It can also be repurposed into ad-hoc medieval armor,", "in case the locals attack.", "", "If the locals attack, please inform management immediately."},
        },
	unlock_office = {
		text = {"Scientists have unlocked the power of accounting", "to boost efficiency."},
	},
    unlock_marine = {
        text = {""},
    },
    unlock_slot_2 = {
        text = {""},
        },
	unlock_slot_3 = {
		text = {"Recent advances quantum gravity unlock 50%", "more free will."},
	},
    unlock_research2 = {
        text = {""},
        },
}


return chatProgression
