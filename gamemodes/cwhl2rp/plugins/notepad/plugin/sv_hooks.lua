--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- Called when an entity's menu option should be handled.
function cwNotepad:EntityHandleMenuOption(player, entity, option, arguments)
	local class = entity:GetClass();

	local uniqueID = cw.entity:QueryProperty(entity, "uniqueID");

	if (class == "cw_notepad") then
		if (entity.text and arguments == "cw_notepadReadOption") then
			if (!player.notepadIDs or !player.notepadIDs[entity.uniqueID]) then
				if (!player.notepadIDs) then
					player.notepadIDs = {};
				end;

				player.notepadIDs[entity.uniqueID] = true;
				netstream.Heavy(player, "ViewNotepad", entity, entity.uniqueID, entity.text);
			else
				netstream.Heavy(player, "ViewNotepad", entity, entity.uniqueID);
			end;
		elseif (arguments == "cw_notepadEditOption") then
			if (uniqueID == player:UniqueID()) then
				if (!player.notepadIDs or !player.notepadIDs[entity.uniqueID]) then
					if (!player.notepadIDs) then
						player.notepadIDs = {};
					end;

					player.notepadIDs[entity.uniqueID] = true;
					netstream.Heavy(player, "EditNotepad", entity, entity.uniqueID, entity.text);
				else
					netstream.Heavy(player, "EditNotepad", entity, entity.uniqueID);
				end;
			else
				cw.player:Notify(player, "#Notepad_CannotEdit");
			end;
		else
			netstream.Heavy(player, "EditNotepad", entity, entity.uniqueID);
		end;
	end;
end;

-- Called when CW has loaded all of the entities.
function cwNotepad:ClockworkInitPostEntity()
	self:LoadNotepad();
end;

-- Called just after data should be saved.
function cwNotepad:PostSaveData()
	self:SaveNotepad();
end;