--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

netstream.Hook("EditNotepad", function(player, entity, text)
	if (IsValid(entity)) then
		if (entity:GetClass() == "cw_notepad") then
			if (player:GetPos():Distance(entity:GetPos()) <= 192 and player:GetEyeTraceNoCursor().Entity == entity) then
				if (string.utf8len(text) > 0) then
					entity:SetText(string.utf8sub(text, 0, 64000));
					cwNotepad:SaveNotepad();
				end;
			end;
		end;
	end;
end);

-- A function to load the notepads.
function cwNotepad:LoadNotepad()
	local notepad = cw.core:RestoreSchemaData( "plugins/notepad/"..game.GetMap() );

	for k, v in pairs(notepad) do
		local entity = ents.Create("cw_notepad");

		cw.player:GivePropertyOffline(v.key, v.uniqueID, entity);

		entity:SetAngles(v.angles);
		entity:SetPos(v.position);
		entity:Spawn();

		if (IsValid(entity)) then
			entity:SetText(v.text);
		end;

		if (!v.moveable) then
			local physicsObject = entity:GetPhysicsObject();

			if (IsValid(physicsObject)) then
				physicsObject:EnableMotion(false);
			end;
		end;
	end;
end;

-- A function to save the notepads.
function cwNotepad:SaveNotepad()
	local notepad = {};

	for k, v in pairs( ents.FindByClass("cw_notepad") ) do
		local physicsObject = v:GetPhysicsObject();
		local moveable;

		if (IsValid(physicsObject)) then
			moveable = physicsObject:IsMoveable();
		end;

		notepad[#notepad + 1] = {
			key = cw.entity:QueryProperty(v, "key"),
			text = v.text,
			angles = v:GetAngles(),
			moveable = moveable,
			uniqueID = cw.entity:QueryProperty(v, "uniqueID"),
			position = v:GetPos()
		};
	end;

	cw.core:SaveSchemaData("plugins/notepad/"..game.GetMap(), notepad);
end;