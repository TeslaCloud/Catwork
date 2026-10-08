--- Defines the server-side `EditNotepad` netstream handler of the Notepad plugin, which writes a player's text to a
-- `cw_notepad`, and `cwNotepad:LoadNotepad` and `cwNotepad:SaveNotepad`, which persist the notepads per map.
--
-- The handler requires a living player who may use the notepad, is within 192 units of it and looking at it, lets
-- only the owner change written text and accepts one edit a second per player. Notepads are stored in
-- `plugins/notepad/<map>` with their owner, text, position, angles and whether they can move.

netstream.Hook('EditNotepad', function(player, entity, text)
  if !isentity(entity) or !IsValid(entity) or entity:GetClass() != 'cw_notepad' or !isstring(text) then return end
  if !player:HasInitialized() or !player:Alive() or player:IsRagdolled() then return end

  local curTime = CurTime()

  if player.cwNextNotepadEdit and player.cwNextNotepadEdit > curTime then return end

  player.cwNextNotepadEdit = curTime + 1

  if player:GetPos():Distance(entity:GetPos()) > 192 or player:GetEyeTraceNoCursor().Entity != entity
  or !hook.Run('PlayerUse', player, entity) then
    return
  end

  -- Same rule as the menu option: written text is the owner's, a blank notepad is anyone's.
  if entity.text and cw.entity:QueryProperty(entity, 'uniqueID') != player:UniqueID() then
    cw.player:Notify(player, '#Notepad_CannotEdit')

    return
  end

  -- A character takes at most four bytes, which bounds the work before the text is cut to size.
  if #text > 0 and #text <= 256000 then
    entity:SetText(string.utf8sub(text, 0, 64000))
    cwNotepad:SaveNotepad()
  end
end)

--- Spawns the notepads saved for the current map.
--
-- Restores each notepad's owner, position, angles and text, and freezes the ones that were
-- frozen when saved.
function cwNotepad:LoadNotepad()
  local notepad = cw.core:RestoreSchemaData('plugins/notepad/'..game.GetMap())

  for k, v in pairs(notepad) do
    local entity = ents.Create('cw_notepad')

    cw.player:GivePropertyOffline(v.key, v.uniqueID, entity)

    entity:SetAngles(v.angles)
    entity:SetPos(v.position)
    entity:Spawn()

    if IsValid(entity) then
      entity:SetText(v.text)
    end

    if !v.moveable then
      local physicsObject = entity:GetPhysicsObject()

      if IsValid(physicsObject) then
        physicsObject:EnableMotion(false)
      end
    end
  end
end

--- Saves every `cw_notepad` on the map to the schema data.
--
-- Writes `plugins/notepad/<map>` with each notepad's owner, text, position, angles and
-- whether it can move.
function cwNotepad:SaveNotepad()
  local notepad = {}

  for k, v in ipairs(ents.FindByClass('cw_notepad')) do
    local physicsObject = v:GetPhysicsObject()
    local moveable

    if IsValid(physicsObject) then
      moveable = physicsObject:IsMoveable()
    end

    notepad[#notepad + 1] = {
      key = cw.entity:QueryProperty(v, 'key'),
      text = v.text,
      angles = v:GetAngles(),
      moveable = moveable,
      uniqueID = cw.entity:QueryProperty(v, 'uniqueID'),
      position = v:GetPos()
    }
  end

  cw.core:SaveSchemaData('plugins/notepad/'..game.GetMap(), notepad)
end
