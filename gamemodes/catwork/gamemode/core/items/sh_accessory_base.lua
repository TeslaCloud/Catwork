--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.isBaseItem = true
ITEM.name = "Accessory Base"
ITEM.model = "models/gibs/hgibs.mdl"
ITEM.weight = 1
ITEM.useText = "Wear"
ITEM.category = "Accessories"
ITEM.description = "An accessory you can wear."
ITEM.isAttachment = true
ITEM.attachmentBone = "ValveBiped.Bip01_Head1"
ITEM.attachmentOffsetAngles = Angle(270, 270, 0)
ITEM.attachmentOffsetVector = Vector(0, 3, 3)

-- Called when a player wears the accessory.
function ITEM:OnWearAccessory(player, bIsWearing)
	if (bIsWearing) then
	else
	end
end

-- Called to get whether a player has the item equipped.
function ITEM:HasPlayerEquipped(player, bIsValidWeapon)
	if (CLIENT) then
		return cw.player:IsWearingAccessory(self)
	else
		return player:IsWearingAccessory(self)
	end
end

-- Called when a player has unequipped the item.
function ITEM:OnPlayerUnequipped(player, extraData)
	player:RemoveAccessory(self)
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position)
	if (player:IsWearingAccessory(self)) then
		cw.player:Notify(player, "#CantDropWhenWearing")
		return false
	end
end

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (player:Alive() and !player:IsRagdolled()) then
		if (!self.CanPlayerWear or self:CanPlayerWear(player, itemEntity) != false) then
			player:WearAccessory(self)
			return true
		end
	else
		cw.player:Notify(player, "#CantDoThisNow")
	end

	return false
end

if (CLIENT) then
	function ITEM:GetClientSideInfo()
		if (!self:IsInstance()) then return end

		if (cw.player:IsWearingAccessory(self)) then
			return "#IsWearing_Yes"
		else
			return "#IsWearing_No"
		end
	end
end
