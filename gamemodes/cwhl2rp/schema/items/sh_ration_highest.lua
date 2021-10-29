--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.name = "Highest Tier Ration Packet"
ITEM.PrintName = "#ITEM_Highest_Tier_Ration_Packet"
ITEM.uniqueID = "ration_highest"
ITEM.model = "models/weapons/w_packatp.mdl"
ITEM.weight = 1.95
ITEM.useText = "Open"
ITEM.description = "#ITEM_Highest_Tier_Ration_Packet_Desc"

-- Called when a player attempts to pick up the item.
function ITEM:CanPickup(player, quickUse, itemEntity)
	if (quickUse) then
		if (!player:CanHoldWeight(self.weight)) then
			cw.player:Notify(player, "You do not have enough inventory space!")

			return false
		end
	end
end

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	cw.player:GiveCash(player, 150, "рацион")

	player:GiveItem(item.CreateInstance("premium_supplements"), true)
	player:GiveItem(item.CreateInstance("premium_supplements"), true)
	player:GiveItem(item.CreateInstance("special_breens_water"), true)
	player:GiveItem(item.CreateInstance("special_breens_water"), true)

	hook.Run("PlayerUseRation", player)
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end
