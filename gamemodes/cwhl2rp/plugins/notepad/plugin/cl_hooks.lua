--[[
	� 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

-- Called when an entity's menu options are needed.
function cwNotepad:GetEntityMenuOptions(entity, options)
	local class = entity:GetClass();

	if (class == "cw_notepad") then
		if (entity:GetDTBool(0)) then
			options["#Notepad_Read"] = "cw_notepadReadOption";
			options["#Notepad_Edit"] = "cw_notepadEditOption";
		else
			options["#Notepad_Write"] = "cw_notepadWriteOption";
		end;
	end;
end;