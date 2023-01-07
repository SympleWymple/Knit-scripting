local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService('TextService')

local Knit = require(ReplicatedStorage.Packages.Knit)
local stallsList = require(ReplicatedStorage.SharedModules.Data.Stalls.StallsList)
local Nametags = require(ReplicatedStorage.SharedModules.Data.Nametags.NametagList)

local InventoryService = Knit.CreateService({Name = "InventoryService", Client = {}})
InventoryService.Client.AddStalls = Knit.CreateSignal()
InventoryService.Client.AddNametag = Knit.CreateSignal()

local NamesToChange = {} --> if there is any data that needs to change


local function getInventory(player: Player, inventoryType: string, list: {[string]: string})
	local DataService = Knit.GetService("DataService")
	local success, profile = DataService.Client:GetProfile(player):await()

	if success then
		local inventory = profile.Inventory1[inventoryType]
		local inventoryToReturn = {}
		for i in pairs(inventory) do
			if NamesToChange[i] then
				inventoryToReturn[i] = true --> set value to true
				inventory[NamesToChange[i]] = true --> say that the name has been changed
				i = NamesToChange[i] --> change name here
			end
			if list[i] then -- if valid cosmetic
				inventoryToReturn[i] = true -- add to return list
			end
		end
		return inventoryToReturn
	end

	return {}
end	

local function listIncludes(list: {[string]: number}, item: number)
	for i, v in pairs(list) do
		if v == item or v.Name == item then
			return true
		end
	end

	return false
end

local function addItem(player: Player, inventoryKey: string, item: string, itemList: {[string]: string})
	local DataService = Knit.GetService("DataService")

	local inventory = DataService.Client:GetProfile(player):expect().Inventory1[inventoryKey] --getInventory(player, inventoryKey, itemList)
	if listIncludes(itemList, item) then
		inventory[item] = true
	else
		return false
	end
end

--> TODO: All information for stalls
function InventoryService:HasStall(player: Player, StallItem: string)
	local inventory = getInventory(player, "Stalls", stallsList)
	if inventory[StallItem] then
		return true
	else
		return false
	end
end

function InventoryService:AddStalls(player: Player, StallItem: string)
	if not InventoryService:HasStall(player, StallItem) then
		self.Client.AddStalls:Fire(player, StallItem)
	end
	addItem(player, "Stalls", StallItem, stallsList)
end

function InventoryService:GetStalls(player: Player)
	return getInventory(player, "Stalls", stallsList)	
end

function InventoryService.Client:LoadStalls(...)
	return self.Server:GetStalls(...)
end


--> TODO: All information for NameTags
function InventoryService.Client:GetEquippedNametag(player: Player)
	local DataService = Knit.GetService("DataService")
	local equippedNametag = DataService:Get(player, "EquippedNametag"):expect()

	if Nametags[equippedNametag] and self:GetNametags(player)[equippedNametag] then
		return equippedNametag
	else
		DataService:Set(player, "EquippedNametag", "None")
		return "None"
	end
end

function InventoryService.Client:GetNametags(player: Player)
	return getInventory(player, "Nametags", Nametags)	
end

function InventoryService:AddNametag(player: Player, nametagType: string)
	if not InventoryService:HasNametag(player, nametagType) then
		self.Client.AddNametag:Fire(player, nametagType)
	end
	addItem(player, "Nametags", nametagType, Nametags)
end

function InventoryService:SetEquippedNametag(player: Player, nametagKey: string)
	local DataService = Knit.GetService("DataService")
	DataService:Set(player, "EquippedNametag", nametagKey, true)
end

function InventoryService:HasNametag(player: Player, nametagType: string)
	local inventory = getInventory(player, "Nametags", Nametags)
	if inventory[nametagType] then
		return true
	else
		return false
	end
end

function InventoryService.Client:LoadNametags(...)
	return self:GetNametags(...), self:GetEquippedNametag(...)
end

return InventoryService
