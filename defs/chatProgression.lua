
local chatProgression = {
	onTurn = {
		[1] = {
			text = {" - Click and drag the windmill", "   onto the island to start making", "   power.", ""},
            sound = "chat_good",
			delay = 0,
		},
		[3] = {
			text = {" - Put the fuel cell near the", "   reactor to give it energy.", ""},
            sound = "chat_good",
			delay = 1.5,
		},
		[5] = {
			text = {" - Add a research lab to unlock", "   more and better tech. Don't put", "   those scientists too close to", "   the fuel cell!", ""},
            sound = "chat_good",
			delay = 1.5,
		},
        [Global.SCORE_DISPLAY_TURN + 1] = {
            text = {"Ah - by the way, here is a readout", "of the power you are generating.",  "Have to keep track of performance,", "after all!", ""}, --score
            sound = "chat_good",
            delay = 1.5,
        },
	},
    seaDamage = {
        [1] = {
            text = {"You dropped pollutants in the", "ocean! ...nobody seems to have", "noticed."},
            sound = "chat_bad",
        },
        [30] = {
            text = {"Your coffee tastes funny. It was", "made using purified and boiled", "seawater sourced locally from an", "ecological paradise.", "", "Weird."},
            sound = "chat_bad",
        },
        [50] = {
            text = {"Local fishermen are having", "unprecedented success. 'The job", "is easy these days,' they say,", "'like skimming dead fish off the", "surface of the sea.'"},
            sound = "chat_bad",
        },
        [80] = {
            text = {"The sea looks greener than you", "remember."},
            sound = "chat_bad",
        },
        [100] = {
            text = {"Small boats crewed by people", "holding golf clubs have been", "sighted in the distance.",  "Your accountants have taken the", "liberty of calling the company", "lawyers in your stead. You have", "been 'strongly encouraged' to", "take the next available flight", "off the island, in case things", "escalate.", "", "You have lost the game.", "Press Ctrl+R to restart."},
            sound = "chat_very_bad",
        },
        
    bankDamage = {
        [1] = {
            text = {"We have paid for your trip here", "with the expectation of making", "a profit. Make sure your energy", "output meets your set quota!"},
            sound = "chat_bad",
            },
        [10] = {
            text = {"Make sure your funds are going", "where they're needed. You millenials", "spend too much on coffee."},
            sound = "chat_bad",
            },
        [20] = {
            text = {"I recall we selected you specifically", "because you don't have a house", "left to mortgage. If we have to", "mortgage this island, I will be", "very upset."},
            sound = "chat_bad",
            },
        [30] = {
            text = {"Your utility bill is how much?", "Maybe you can save on heating", "by putting the science labs next", "to the reactors."},
            sound = "chat_bad",
            },
        [40] = {
            text = {""},
            sound = "chat_bad",
            },
        [50] = {
            text = {""},
            sound = "chat_bad",
            },
        [60] = {
            text = {""},
            sound = "chat_bad",
            },
        [70] = {
            text = {""},
            sound = "chat_bad",
            },
        [80] = {
            text = {""},
            sound = "chat_bad",
            },
        [90] = {
            text = {""},
            sound = "chat_bad",
            },
        [100] = {
            text = {""},
            sound = "chat_very_bad",
            },
        },
    },
    unlock_slot_2 = {
        text = {"Negotiations with the locals have", "netted us access to local airspace.", "We can now import a greater variety", "of components!"},
        sound = "chat_good",
        },
    unlock_rope = {
		text = {"The scientists have invented rope,", "to hold things together. They say", "they plan to invent the bicycle", "next."},
        sound = "chat_good",
	},
	unlock_solar = {
		text = {"The scientists have invented solar", "panels! They’re not very efficient,", "but it’s not like that sunlight was", "doing anything else anyway."},
        sound = "chat_good",
	},
    unlock_wsad = {
        text = {"The scientists have discovered", "an instruction manual! It is very", "dusty.  It says:", "'You can rotate the blocks with", "A/D, Z/X, space, or the arrow", "keys.'"},
        sound = "chat_good",
    },
    unlock_office = {
		text = {"The scientists have invented", "offices, saddling other people", "with the responsibility for making", "this undertaking more efficient."},
        sound = "chat_good",
	},
    unlock_slot_3 = {
		text = {"The scientists have applied recent", "advances in quantum gravity research", "to grant you 50% more free will."},
        sound = "chat_good",
	},
    unlock_marine = {
        text = {"The scientists have invented marine", "conservation. The process consists", "of putting fish in a box that does", "not contain nuclear reactors.", "", "Might net you some brownie points."},
        sound = "chat_good",
    },
    unlock_chain = {
        text = {"The scientists have invented chain!", "Chain will stretch less under tension", "than rope does. It can also be", "repurposed into ad-hoc medieval", "armor, in case the locals attack.", "", "If the locals attack, please inform", "management immediately."},
        sound = "chat_good",
        },
    unlock_research2 = {
        text = {"The scientists have invented 75-hour", "work weeks! Management has mandated", "the immediate implementation of this", "new technology."},
        sound = "chat_good",
    },
    unlock_light = {
        text = {"Scientists have condensed the", "power of two suns into one light", "bulb. Place the light bulb next to", "a solar panel to power other light", "bulbs.", "", "Our perpetual motion device is", "patent pending."},
        sound = "chat_good",
        },
    unlock_fuelcell2 = {
        text = {"The scientists have invented", "improved reactor fuel! This",  "substance is even less compatible",  "with humans than the usual stuff."},
        sound = "chat_good",
        },
    unlock_no_rope = {
        text = {"Management has noticed chain exists,", "and have decreed that all remaining", "rope be disposed of immediately."},
        sound = "chat_good",
        },
    unlock_slot4 = {
        text = {"Previous quantum gravity research", "has granted scientists the free", "will required to continue research", "on quantum gravity. Your free", "will has been increased another", "33% by association."},
        sound = "chat_good",
        },
    unlock_fan = {
        text = {"Wind turbine efficiency can now", "be improved by positioning fans", "next to the turbines. The scientists", "suggest that efficiency might be", "improved even further by placing", "turbines in the open air, instead of", "under twelve reactors."},
        sound = "chat_good",
    },
    unlock_nano = {
        text = {"The scientists have improved our", "chains by putting more carbon in", "them, calling the new product ‘carbon", "nanotubes’. Dissenters calling the", "new product ‘but it’s just steel’", "have been fired."},
        sound = "chat_good",
    },
    unlock_office2 = {
        text = {"Our social scientists have improved", "the productivity of our offices by", "using a new cubicle structure,", "boosting output 300%. Each cubicle", "contains heat packs for muscle", "pains caused by maintaining", "uncomfortable positions for long", "periods."},
        sound = "chat_good",
    },
    unlock_more_nano = { --one additional nano
        text = {"The scientists have optimised", "nanotube production. There are", "now more nanotubes available."},
        sound = "chat_good",
        },
    
    unlock_perpetual = {
        text = {"The scientists are working on a", "method to transport their new", "perpetual motion machine to", "somewhere...safer."},
        sound = "chat_good",
    },
}


return chatProgression
