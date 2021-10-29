--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.name = "Standard Tier Ration Packet"
ITEM.PrintName = "#ITEM_Standard_Tier_Ration_Packet"
ITEM.uniqueID = "ration_standard"
ITEM.model = "models/weapons/w_packatc.mdl"
ITEM.weight = 1.38
ITEM.useText = "Open"
ITEM.description = "#ITEM_Standard_Tier_Ration_Packet_Desc"

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
	cw.player:GiveCash(player, 50, "рацион")

	player:GiveItem(item.CreateInstance("citizen_supplements"), true)
	player:GiveItem(item.CreateInstance("smooth_breens_water"), true)

	hook.Run("PlayerUseRation", player)
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end
