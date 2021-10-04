
local IterableMap = require("include/IterableMap")
local util = require("include/util")

local SoundHandler = require("soundHandler")
local soundFiles = util.LoadDefDirectory("sounds/defs")

local api = {}
local world

local font = love.graphics.newFont(70)

-- First eligible tracks are used as start music
local trackList = {
	'01_drums',
	'01_rhythm',
	'01_solo_1',
	'01_solo_2',
	'01_solo_3',
	'01_solo_4',
	'01_solo_5',
	'01_solo_6',
	'02_drums',
	'02_rhythm',
	'02_solo_7',
	'02_solo_8',
	'03_transition',
	'03_drums_rhythm',
	'03_solo_9',
	'03_solo_10',
}

local fallbackTrack = {
	'01_solo_1',
	'02_drums',
	'03_solo_9',
}

local fadeRate = 1

local currentTrack = {}
local queuedTracks = {}
local currentTrackRemaining = 0
local trackRunning = false

function api.StopCurrentTrack()
	currentTrackRemaining = 0
end

local fadeRate = 1

local currentTrack = nil
local queuedTracks = {}
local currentTrackRemaining = 0

local function GetTracks()
	local foundTrack = {}
	local seaDamage = math.max(0, math.min(1, GameHandler.GetSeaDamage()))
	
	for i = 1, #trackList do
		local track = soundFiles[trackList[i]]
		if track.handler and not foundTrack[track.handler] then
			if seaDamage > track.minHealth and seaDamage <= track.maxHealth then
				foundTrack[track.handler] = {sound = trackList[i]}
			end
		end
	end
	
	for i = 1, 3 do
		if not foundTrack[i] then
			foundTrack[i] = {sound = fallbackTrack[i]}
		end
		foundTrack[i].id = 100 + i
	end
	
	return foundTrack
end

function api.Update(dt)
	currentTrackRemaining = (currentTrackRemaining or 0) - dt
	if currentTrackRemaining < 0 then
		if world.MusicEnabled()  then
			if trackRunning then
				for i = 1, #currentTrack do
					SoundHandler.StopSound(currentTrack[i].sound .. '_track' .. currentTrack[i].id, false)
				end
			end
			currentTrack = GetTracks()
			currentTrackRemaining = soundFiles[currentTrack[1].sound].duration or 38.4
			print(duration)
			for i = 1, #currentTrack do
				SoundHandler.PlaySound(currentTrack[i].sound, false, '_track' .. currentTrack[i].id, fadeRate, fadeRate, 0)
			end
		elseif trackRunning then
			for i = 1, #currentTrack do
				SoundHandler.StopSound(currentTrack[i].sound .. '_track' .. currentTrack[i].id, false)
			end
			trackRunning = false
		end
	end
end

function api.Initialize(newWorld)
	world = newWorld
	api.StopCurrentTrack()
end

return api