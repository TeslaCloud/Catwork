--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM.name = "Notepad";
ITEM.PrintName = "#Notepad_Title";
ITEM.cost = 5;
ITEM.model = "models/props_lab/clipboard.mdl";
ITEM.weight = 0.1;
ITEM.access = "1v";
ITEM.classes = {CLASS_EMP, CLASS_EOW};
ITEM.business = true;
ITEM.description = "A clean notepad, useful to note taking.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	local trace = player:GetEyeTraceNoCursor();

	if (trace.HitPos:Distance( player:GetShootPos() ) <= 192) then
		local entity = ents.Create("cw_notepad");

		cw.player:GiveProperty(player, entity);

		entity:SetPos(trace.HitPos);
		entity:Spawn();

		if (IsValid(itemEntity)) then
			local physicsObject = itemEntity:GetPhysicsObject();

			entity:SetPos( itemEntity:GetPos() );
			entity:SetAngles( itemEntity:GetAngles() );

			if (IsValid(physicsObject)) then
				if (!physicsObject:IsMoveable()) then
					physicsObject = entity:GetPhysicsObject();

					if (IsValid(physicsObject)) then
						physicsObject:EnableMotion(false);
					end;
				end;
			end;
		else
			cw.entity:MakeFlushToGround(entity, trace.HitPos, trace.HitNormal);
		end;
	else
		cw.player:Notify(player, "You cannot drop notepads that far away!");

		return false;
	end;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

