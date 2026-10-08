--- Client-side hooks of the Notepad plugin; `GetEntityMenuOptions` gives a written `cw_notepad` the Read and Edit menu
-- options and a blank one the Write option.

--- Called when an entity's menu options are needed; adds the notepad's options.
--
-- A written notepad offers Read and Edit, a blank one offers Write.
--
-- @param entity [Entity The entity the menu is for]
-- @param options [Map The menu options, display text to option value, modified in place]
function cwNotepad:GetEntityMenuOptions(entity, options)
  local class = entity:GetClass()

  if class == 'cw_notepad' then
    if entity:GetDTBool(0) then
      options['#Notepad_Read'] = 'cw_notepadReadOption'
      options['#Notepad_Edit'] = 'cw_notepadEditOption'
    else
      options['#Notepad_Write'] = 'cw_notepadWriteOption'
    end
  end
end
