--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]


ITEM.name = "Container Base"
ITEM.model = "models/props_junk/garbage_bag001a.mdl"
ITEM.weight = 2
ITEM.category = "Storage"
ITEM.isRareItem = true
ITEM.description = "A basic container to hold other items."
ITEM.isContainer = true
ITEM.storageWeight = 5
ITEM.storageSpace = 10

ITEM:AddData("Inventory", nil)
ITEM:AddData("Cash", 0)

function ITEM:OnSaved(newData)
	if (newData["Inventory"] != nil) then
		newData["Inventory"] = cw.inventory:ToSaveable(newData["Inventory"])
	end
end

function ITEM:OnLoaded()
	local inventory = (self.data and self.data.Inventory) or self.Inventory

	if (inventory != nil) then
		self:SetData("Inventory", cw.inventory:ToLoadable(inventory))
	end
end

if (SERVER) then
function ITEM:GetInventory()
		local inventory = self:GetData("Inventory")

		if (inventory == nil) then
			self:SetData("Inventory", {})
		end

		return inventory
	end

function ITEM:HasItem(itemTable)
		if (isstring(itemTable)) then
			cw.inventory:HasItemByID(self:GetInventory(), itemTable)
		else
			cw.inventory:HasItemInstance(self:GetInventory(), itemTable)
		end
	end

function ITEM:RemoveFromInventory(itemTable)
		if (isstring(itemTable)) then
			cw.inventory:RemoveUniqueID(self:GetInventory(), itemTable)
		else
			cw.inventory:RemoveInstance(self:GetInventory(), itemTable)
		end
	end

function ITEM:InventoryAsItemsList()
		return cw.inventory:GetAsItemsList(self:GetInventory())
	end

function ITEM:AddToInventory(itemTable)
		cw.inventory:AddInstance(self:GetInventory(), itemTable)
	end

function ITEM:GetCash()
		return (self.data and self.data.Cash) or self.Cash
	end
end

function ITEM:OnUse(player, itemEntity)
	self:OpenFor(player, itemEntity)

	return false
end

function ITEM:OpenFor(player, itemEntity)
	local inventory = self:GetInventory()
	local cash = self:GetCash()
	local name = self.PrintName

	cw.storage:Open(player, {
		name = name,
		weight = self.storageWeight,
		space = self.storageSpace,
		entity = itemEntity or false,
		distance = 192,
		cash = cash,
		inventory = inventory,
		OnGiveCash = function(player, storageTable, cash)
			self:SetData("Cash", self:GetCash() + cash)
		end,
		OnTakeCash = function(player, storageTable, cash)
			self:SetData("Cash", self:GetCash() - cash)
		end
	})
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end
