
local util = require("include/util")

local EffectsHandler = require("effectsHandler")
local ComponentHandler = require("componentHandler")
local PowerupHandler = require("powerupHandler")

local self = {}
local world

local shopSpeed = 1.25
local shopItemSpots = 2
local shopMoveWidth = 280
local shopTopProp = 0.25
local shopGapProp = 0.25
local shopGap = 280
local shopPos = {1760, 220}

local powerupRadius = 180

local function GetShopPos(index)
	local windowX, windowY = love.window.getMode()
	
	local increment = windowY*shopGapProp
	shopPos[1] = windowX*0.92
	shopPos[2] = windowY*shopTopProp
	shopMoveWidth = windowX*0.135
	return world.ScreenToWorld(util.Add(shopPos, {self.position*shopMoveWidth, (index - 1)*increment}))
end

local function UpdateShopGeo()
	shopTopProp = 1 / (shopItemSpots + 1)
	shopGapProp = shopTopProp
end

local function RestockItems()
	for i = 1, #self.items do
		local item = self.items[i]
		if item and (not item.isPowerup) and item.IsInShop() then
			ComponentHandler.Remove(item)
		end
	end
	
	local draw = DeckHandler.GetNextDraw()
	shopItemSpots = #draw
	UpdateShopGeo()
	
	self.items = {}
	for i = 1, #draw do
		local nextItem = draw[i]
		if PowerupHandler.IsPowerup(nextItem) then
			self.items[#self.items + 1] = {
				isPowerup = true,
				powerupType = nextItem,
			}
		else
			local compData = {
				inShop = true,
			}
			local component = ComponentHandler.SpawnComponent(nextItem, GetShopPos(i), compData)
			self.items[#self.items + 1] = component
		end
	end
	self.wantRestock = false
end

local function CheckRestock(dt)
	if self.wantRestock then
		if self.position < 1 then
			self.position = self.position + dt*shopSpeed
		end
		if self.position >= 1 then
			self.position = 1
			RestockItems()
		end
	else
		if self.position > 0 then
			self.position = self.position - dt*shopSpeed
		end
		if self.position <= 0 then
			self.position = 0
		end
	end
end

local function SetItemPositions()
	for i = 1, #self.items do
		local item = self.items[i]
		if item and (not item.isPowerup) and item.IsInShop() then
			item.SetComponentPosition(GetShopPos(i))
		end
	end
end

--------------------------------------------------
-- API
--------------------------------------------------

function self.ShopSelectAllowed()
	return not self.wantRestock
end

function self.ItemSelected(item, index)
	GameHandler.DoTurn()
	if item then
		item.inShop = false
	end
	if index then
		self.items[index] = false
	end
	self.wantRestock = true
end

function self.MousePressed(x, y)
	if self.wantRestock then
		return
	end
	for i = 1, #self.items do
		if self.items[i] and self.items[i].isPowerup then
			if util.PosInCircle({x, y}, GetShopPos(i), powerupRadius) then
				PowerupHandler.SelectPowerup(self.items[i].powerupType)
				self.ItemSelected(false, i)
			end
		end
	end
end

--------------------------------------------------
-- Updating
--------------------------------------------------

function self.Update(dt)
	CheckRestock(dt)
	SetItemPositions(dt)
end

function self.Draw(drawQueue)
	for i = 1, #self.items do
		if self.items[i] and self.items[i].isPowerup then
			PowerupHandler.DrawPowerup(drawQueue, self.items[i].powerupType, GetShopPos(i))
		end
	end
end

function self.Initialize(parentWorld)
	world = parentWorld
	
	self.items = {}
	self.wantRestock = true
	self.position = 1
end

return self