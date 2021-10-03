
local util = require("include/util")

local EffectsHandler = require("effectsHandler")
local ComponentHandler = require("componentHandler")
local Resources = require("resourceHandler")

local self = {}
local world

--------------------------------------------------
-- API
--------------------------------------------------

--------------------------------------------------
-- Updating
--------------------------------------------------

function self.Update(dt)
end

function self.DrawInterface(drawQueue)
end

function self.Initialize(parentWorld)
end

return self