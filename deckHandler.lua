
local util = require("include/util")

local EffectsHandler = require("effectsHandler")
local ComponentHandler = require("componentHandler")
local PowerupHandler = require("powerupHandler")

local self = {}
local world

local baseRestockRates = {
	fuelcell = 3,
	marine = 0,
	nuclear_generator = 2,
	office = 2,
	research = 2,
	solar = 4,
	wind = 4,


}

local initialStock = {

}

--------------------------------------------------
-- API
--------------------------------------------------

function self.GetNextDraw()
	return {"solar", "solar", "solar"}
end

--------------------------------------------------
-- Updating
--------------------------------------------------

function self.Initialize(parentWorld)
	world = parentWorld
end

return self