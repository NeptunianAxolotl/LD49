
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
	'01_solo_fake',
	'02_drums',
	'02_rhythm',
	'02_solo_7',
	'02_solo_8',
	'02_solo_fake',
	'03_transition',
	'03_drums_rhythm',
	'03_solo_9',
	'03_solo_10',
	'03_solo_fake',
}

local fallbackTrack = {
	'01_solo_fake',
	'01_solo_fake',
	'01_solo_fake',
}

local currentTrack = {}
local trackRunning = false
local fadeRate = 1
local idCycle = 1
local currentTrackRemaining = 0

function api.StopCurrentTrack()
	currentTrackRemaining = 0
end

local function GetTracks()
	idCycle = 3 - idCycle
	local foundTrack = {}
	local seaDamage = math.max(0, math.min(1, GameHandler.GetSeaDamage()))
	
	for i = 1, #trackList do
		local track = soundFiles[trackList[i]]
		if track.handler and not foundTrack[track.handler] then
			if seaDamage >= track.minHealth and (seaDamage < track.maxHealth or (seaDamage == 1 and track.maxHealth == 1)) then
				foundTrack[track.handler] = {sound = trackList[i]}
			end
		end
	end
	
	for i = 1, 3 do
		if not foundTrack[i] then
			foundTrack[i] = {sound = fallbackTrack[i]}
		end
		foundTrack[i].id = 10*i + idCycle
	end
	util.Permute(trackList)
	
	return foundTrack
end

function api.Update(dt)
	currentTrackRemaining = (currentTrackRemaining or 0) - dt
	if currentTrackRemaining < 0 then
		if world.MusicEnabled() then
			if trackRunning then
				for i = 1, #currentTrack do
					SoundHandler.StopSound(currentTrack[i].sound .. '_track' .. currentTrack[i].id, false)
				end
			end
			currentTrack = GetTracks()
			currentTrackRemaining = 0
			for i = 1, 3 do
				currentTrackRemaining = math.max(currentTrackRemaining, soundFiles[currentTrack[i].sound].duration or Global.DEFAULT_SOUND_DURATION)
			end
			currentTrackRemaining = currentTrackRemaining
			util.PrintTable(currentTrack)
			trackRunning = true
			for i = 1, #currentTrack do
				SoundHandler.PlaySound(currentTrack[i].sound, false, '_track' .. currentTrack[i].id, fadeRate, fadeRate, 0.1)
			end
			local sources = love.audio.pause()
			local function StartSound()
				love.audio.play(sources)
			end
			Delay.Add(10, StartSound)
		elseif trackRunning then
			print("trackRunning", currentTrackRemaining, trackRunning, world.MusicEnabled())
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