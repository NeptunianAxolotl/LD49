
local util = require("include/util")
local Font = require("include/font")

local EffectsHandler = require("effectsHandler")
local ComponentHandler = require("componentHandler")
local Resources = require("resourceHandler")

local chatProgression = require("defs/chatProgression")

local self = {}
local world

--------------------------------------------------
-- API
--------------------------------------------------

function self.AddMessage(text, timer, turns, color)
	if timer == nil then
		timer = 5
	end
	if turns == nil then
		turns = false
	end

	if color == nil then
		color = {}
		color.r = 1
		color.g = 1
		color.b = 1
	end
	local line = {
		consoleText = text,
		consoleTimer = timer,
		consoleTurnTimer = turns,
		consoleColorR = color.r,
		consoleColorG = color.g,
		consoleColorB = color.b,
	}
	table.insert(self.lines, line)
end

function self.DrawConsole()
	local botPad = love.graphics:getHeight() - Global.CONSOLE_BOTTOM + #self.lines*25

	for i = 1, #self.lines do
		local line = self.lines[i]
		love.graphics.setColor(
			line.consoleColorR,
			line.consoleColorG,
			line.consoleColorB,
			math.min(1, line.consoleTimer)
		)
		
		Font.SetSize(1)
		love.graphics.print(line.consoleText, 50, botPad - (i * 25))
		love.graphics.setColor(1,1,1)
	end
end

function self.RemoveMessage(index)
	table.remove(self.lines, index)
end

function self.ChatTurn(turn)
	for i = #self.lines, 1, -1 do
		local line = self.lines[i]
		if line.consoleTurnTimer then
			line.consoleTurnTimer = line.consoleTurnTimer - 1
			if line.consoleTurnTimer <= 0 then
				line.consoleTurnTimer = false
			end
		end
	end
	
	if chatProgression[turn] then
		local msg = chatProgression[turn]
		local function AddFunc()
			for i = #msg.text, 1, -1 do
				self.AddMessage(msg.text[i], msg.timer or 1.4, msg.turns or 1, msg.color)
			end
		end
		Delay.Add(msg.delay or 1.5, AddFunc)
	end
end

--------------------------------------------------
-- Updating
--------------------------------------------------

function self.Update(dt)
	if self.lines then
		for i = #self.lines, 1, -1 do
			local line = self.lines[i]
			if line.consoleTimer and not line.consoleTurnTimer then
				line.consoleTimer = line.consoleTimer - dt
				if line.consoleTimer < 0 then
					self.RemoveMessage(i)
				end
			end
		end
	end
end

function self.DrawInterface()
	self.DrawConsole()
end

function self.Initialize(parentWorld)
	world = parentWorld
	self.lines = {}
end

return self