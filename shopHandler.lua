
local util = require("include/util")

local EffectsHandler = require("effectsHandler")
local ComponentHandler = require("componentHandler")
local PowerupHandler = require("powerupHandler")

local self = {}
local world

local shopSpeed = 1.2
local shopItemSpots = 3
local shopMoveWidth = 280
local shopGap = 280
local shopPos = {1760, 220}

local powerupRadius = 180
local powerupChance = 0.25

local function GetShopPos(index)
	return util.Add(shopPos, {self.position*shopMoveWidth, (index - 1)*shopGap})
end

local function RestockItems()
	for i = 1, #self.items do
		local item = self.items[i]
		if item and (not item.isPowerup) and item.IsInShop() then
			ComponentHandler.Remove(item)
		end
	end
	
	self.items = {}
	for i = 1, shopItemSpots do
		if powerupChance < math.random() then
			self.items[#self.items + 1] = {
				isPowerup = true,
				powerupType = PowerupHandler.GetRandomPowerup(),
			}
		else
			local compData = {
				inShop = true,
			}
			local componentType = util.SampleList(ComponentHandler.GetComponentDefList())
			local component = ComponentHandler.SpawnComponent(componentType, GetShopPos(i), compData)
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
			PowerupHandler.DrawPowerup(drawQueue, self.items[i].powerupType, util.Add(shopPos, {self.position*shopMoveWidth, (i - 1)*shopGap}))
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