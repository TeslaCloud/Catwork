--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.name = "Boxed Bag"
ITEM.PrintName = "#ITEM_Boxed_Bag"
ITEM.cost = 15
ITEM.model = "models/props_junk/cardboard_box004a.mdl"
ITEM.weight = 0.5
ITEM.access = "1v"
ITEM.useText = "Open"
ITEM.category = "Storage"
ITEM.business = true
ITEM.description = "#ITEM_Boxed_Bag_Desc"

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (player:HasItemByID("small_bag") and table.Count(player:GetItemsByID("small_bag")) >= 2) then
		cw.player:Notify(player, "You've hit the bags limit!")

		return false
	end

	player:GiveItem(item.CreateInstance("small_bag"))
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end
