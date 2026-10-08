--- Client-side netstream handlers of the Notepad plugin: `ViewNotepad` opens the `cwViewNotepad` window and
-- `EditNotepad` the `cwEditNotepad` window for a notepad entity.
--
-- The server sends a notepad's text only the first time, so it is cached in `cwNotepad.notepadIDs` by the notepad's ID
-- and reused when a later message arrives without text.

netstream.Hook('ViewNotepad', function(entity, uniqueID, text)
  if IsValid(entity) then
    if IsValid(cwNotepad.notepadPanel) then
      cwNotepad.notepadPanel:Close()
      cwNotepad.notepadPanel:Remove()
    end

    if !text then
      if cwNotepad.notepadIDs[uniqueID] then
        text = cwNotepad.notepadIDs[uniqueID]
      else
        text = L('#Notepad_Error')
      end
    else
      cwNotepad.notepadIDs[uniqueID] = text
    end

    cwNotepad.notepadPanel = vgui.Create('cwViewNotepad')
    cwNotepad.notepadPanel:SetEntity(entity)
    cwNotepad.notepadPanel:Populate(text)
    cwNotepad.notepadPanel:MakePopup()

    gui.EnableScreenClicker(true)
  end
end)

netstream.Hook('EditNotepad', function(entity, uniqueID, text)
  if IsValid(entity) then
    if IsValid(cwNotepad.notepadPanel) then
      cwNotepad.notepadPanel:Close()
      cwNotepad.notepadPanel:Remove()
    end

    if !text then
      if cwNotepad.notepadIDs[uniqueID] then
        text = cwNotepad.notepadIDs[uniqueID]
      else
        text = ''
      end
    else
      cwNotepad.notepadIDs[uniqueID] = text
    end

    cwNotepad.notepadPanel = vgui.Create('cwEditNotepad')
    cwNotepad.notepadPanel:SetEntity(entity)
    cwNotepad.notepadPanel:Populate(text)
    cwNotepad.notepadPanel:MakePopup()

    gui.EnableScreenClicker(true)
  end
end)
