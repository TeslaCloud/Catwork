--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).


ITEM.baseItem = "accessory_base"
ITEM.name = "Backpack";
ITEM.batch = 1;
ITEM.useText = "Pickup";
ITEM.cost = 40;
ITEM.model = "models/props_c17/oildrum001.mdl";
ITEM.weight = 2;
ITEM.access = "V";
ITEM.category = "Other";
ITEM.business = true;
ITEM.uniqueID = "backpack_large";
ITEM.description = "A green army backpack that's heavily worn.";
ITEM.isAttachment = true;
ITEM.attachmentBone = "ValveBiped.Bip01_Spine4";
ITEM.attachmentOffsetAngles = Angle(90, -22.209, 180);
ITEM.attachmentOffsetVector = Vector(-14.78, -3.803, 0.216);

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end

function ITEM:OnWearAccessory(player, bIsWearing)
	if (bIsWearing) then
		cw.player:CreateGear(player, "Backpack", self)
	else
		cw.player:RemoveGear(player, "Backpack")
	end
end
--]]