--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.name = "Boxed Backpack"
ITEM.PrintName = "#ITEM_Boxed_Backpack"
ITEM.cost = 25
ITEM.model = "models/props_junk/cardboard_box004a.mdl"
ITEM.weight = 1
ITEM.access = "1v"
ITEM.useText = "Open"
ITEM.category = "Storage"
ITEM.business = true
ITEM.description = "#ITEM_Boxed_Backpack_Desc"

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (player:HasItemByID("backpack") and table.Count(player:GetItemsByID("backpack")) >= 1) then
		cw.player:Notify(player, "You've hit the backpacks limit!")

		return false
	end

	player:GiveItem(item.CreateInstance("backpack"))
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end
