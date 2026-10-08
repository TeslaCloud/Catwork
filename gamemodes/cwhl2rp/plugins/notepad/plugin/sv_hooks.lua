--[[
  © 2012 CloudSixteen.com do not share, re-distribute or modify
  without permission of its author (kurozael@gmail.com).
--]]

--- Called when an entity's menu option is chosen; opens a notepad for reading or editing.
--
-- The notepad text is only sent the first time a player opens that text (tracked by its
-- CRC in `player.notepadIDs`); later the client uses its cached copy. Only the notepad's
-- owner may edit written text; anyone may write on a blank notepad.
--
-- @param player [Player The player who chose the option]
-- @param entity [Entity The entity the option was chosen on]
-- @param option [String The option's display text]
-- @param arguments [String The option value, such as `cw_notepadReadOption`]
function cwNotepad:EntityHandleMenuOption(player, entity, option, arguments)
  local class = entity:GetClass()

  local uniqueID = cw.entity:QueryProperty(entity, 'uniqueID')

  if class == 'cw_notepad' then
    if entity.text and arguments == 'cw_notepadReadOption' then
      if !player.notepadIDs or !player.notepadIDs[entity.uniqueID] then
        if !player.notepadIDs then
          player.notepadIDs = {}
        end

        player.notepadIDs[entity.uniqueID] = true
        netstream.Heavy(player, 'ViewNotepad', entity, entity.uniqueID, entity.text)
      else
        netstream.Heavy(player, 'ViewNotepad', entity, entity.uniqueID)
      end
    elseif arguments == 'cw_notepadEditOption' then
      if uniqueID == player:UniqueID() then
        if !player.notepadIDs or !player.notepadIDs[entity.uniqueID] then
          if !player.notepadIDs then
            player.notepadIDs = {}
          end

          player.notepadIDs[entity.uniqueID] = true
          netstream.Heavy(player, 'EditNotepad', entity, entity.uniqueID, entity.text)
        else
          netstream.Heavy(player, 'EditNotepad', entity, entity.uniqueID)
        end
      else
        cw.player:Notify(player, '#Notepad_CannotEdit')
      end
    else
      netstream.Heavy(player, 'EditNotepad', entity, entity.uniqueID)
    end
  end
end

--- Called after Catwork has loaded the map entities; restores the saved notepads.
function cwNotepad:ClockworkInitPostEntity()
  self:LoadNotepad()
end

--- Called after data is saved; saves the notepads.
function cwNotepad:PostSaveData()
  self:SaveNotepad()
end
