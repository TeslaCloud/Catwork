--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

netstream.Hook("ViewNotepad", function(entity, uniqueID, text)
	if (IsValid(entity)) then
		if (IsValid(cwNotepad.notepadPanel)) then
			cwNotepad.notepadPanel:Close();
			cwNotepad.notepadPanel:Remove();
		end;

		if (!text) then
			if (cwNotepad.notepadIDs[uniqueID]) then
				text = cwNotepad.notepadIDs[uniqueID];
			else
				text = "ERROR!";
			end;
		else
			cwNotepad.notepadIDs[uniqueID] = text;
		end;

		cwNotepad.notepadPanel = vgui.Create("cwViewNotepad");
		cwNotepad.notepadPanel:SetEntity(entity);
		cwNotepad.notepadPanel:Populate(text);
		cwNotepad.notepadPanel:MakePopup();

		gui.EnableScreenClicker(true);
	end;
end);

netstream.Hook("EditNotepad", function(entity, uniqueID, text)
	if (IsValid(entity)) then
		if (IsValid(cwNotepad.notepadPanel)) then
			cwNotepad.notepadPanel:Close();
			cwNotepad.notepadPanel:Remove();
		end;

		if (!text) then
			if (cwNotepad.notepadIDs[uniqueID]) then
				text = cwNotepad.notepadIDs[uniqueID];
			else
				text = "";
			end;
		else
			cwNotepad.notepadIDs[uniqueID] = text;
		end;

		cwNotepad.notepadPanel = vgui.Create("cwEditNotepad");
		cwNotepad.notepadPanel:SetEntity(entity);
		cwNotepad.notepadPanel:Populate(text);
		cwNotepad.notepadPanel:MakePopup();

		gui.EnableScreenClicker(true);
	end;
end);