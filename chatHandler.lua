
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

function self.AddTurnMessageRaw(message)
	local function AddFunc()
		for i = #message.text, 1, -1 do
			self.AddMessage(message.text[i], message.timer or 1.4, message.turns or 1, message.color)
		end
	end
	Delay.Add(message.delay or 0.7, AddFunc)
end

function self.AddTurnMessage(messageName)
	local message = chatProgression[messageName]
	if message then
		self.AddTurnMessageRaw(message)
	end
end

function self.DrawConsole()
	local windowX, windowY = love.window.getMode()
	local drawPos = world.ScreenToInterface({0, windowY*0.25})
	local botPad = drawPos[2] + #self.lines*25

	for i = 1, #self.lines do
		local line = self.lines[i]
		love.graphics.setColor(
			line.consoleColorR,
			line.consoleColorG,
			line.consoleColorB,
			math.min(1, line.consoleTimer)
		)
		
		Font.SetSize(1)
		love.graphics.print(line.consoleText, 80, botPad - (i * 25))
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
	
	if chatProgression.onTurn[turn] then
		local message = chatProgression.onTurn[turn]
		self.AddTurnMessageRaw(message)
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