
local util = require("include/util")

local EffectsHandler = require("effectsHandler")
local ComponentHandler = require("componentHandler")

local self = {}
local world

local shopSpeed = 1.2
local shopItemSpots = 3
local shopMoveWidth = 280
local shopGap = 280
local shopPos = {1760, 220}

local function RestockItems()
	for i = 1, #self.items do
		local component = self.items[i]
		if component.IsInShop() then
			ComponentHandler.Remove(component)
		end
	end
	
	self.items = {}
	for i = 1, shopItemSpots do
		local compData = {
			inShop = true,
		}
		local component = ComponentHandler.SpawnComponent("solar", util.Add(shopPos, {self.position*shopMoveWidth, (i - 1)*shopGap}), compData)
		self.items[#self.items + 1] = component
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
		local component = self.items[i]
		if component.IsInShop() then
			component.SetComponentPosition(util.Add(shopPos, {self.position*shopMoveWidth, (i - 1)*shopGap}))
		end
	end
end


--------------------------------------------------
-- API
--------------------------------------------------

function self.ShopSelectAllowed()
	return not self.wantRestock
end

function self.ItemSelected(component)
	component.inShop = false
	self.wantRestock = true
end

--------------------------------------------------
-- Updating
--------------------------------------------------

function self.Update(dt)
	CheckRestock(dt)
	SetItemPositions(dt)
end

function self.Draw(drawQueue)

end

function self.Initialize(parentWorld)
	world = parentWorld
	
	self.items = {}
	self.wantRestock = true
	self.position = 1
end

return self