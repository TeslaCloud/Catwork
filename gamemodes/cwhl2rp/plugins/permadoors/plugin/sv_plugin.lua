--- Defines `cwPermaDoors:SetPermaDoor` and `cwPermaDoors:ResetPermaDoor`, which assign a door to a character or mark it
-- vacant and save the result.
--
-- A character gets a random `PermaDoorSecret` key the first time it is given a door, and every door it owns stores
-- that key. Either way the door is made unownable, so it cannot be bought, and its name and text are updated.

--- Makes a door permanently owned by a player's character and saves it.
--
-- The character gets a `PermaDoorSecret` key the first time it is given a door; the door stores
-- that key, becomes unownable and shows the title with the owner's name as its text.
-- @param player [Player The new owner]
-- @param door [Entity The door to assign]
-- @param title [String Name shown on the door]
-- @see cwPermaDoors:ResetPermaDoor
function cwPermaDoors:SetPermaDoor(player, door, title)
  local secretKey = player:GetCharacterData('PermaDoorSecret')

  if !secretKey then
    secretKey = 'doorkey_'..math.random(0, 999999)..'_'..player:SteamID64()
    player:SetCharacterData('PermaDoorSecret', secretKey)
  end

  self.stored[door] = self.stored[door] or {}
  self.stored[door].secret = secretKey
  self.stored[door].text = player:Name()
  self.stored[door].name = title
  self.stored[door].position = door:GetPos()

  cw.entity:SetDoorUnownable(door, true)
  cw.entity:SetDoorText(door, player:Name())
  cw.entity:SetDoorName(door, title)

  self:SavePermaDoors()
end

--- Removes the owner of a permanent door and saves it as vacant.
--
-- The door keeps being unownable, gets a new random secret that no character holds and shows
-- `#Door_Vacant` as its text.
-- @param door [Entity The door to reset]
-- @param title [String Name shown on the door]
-- @see cwPermaDoors:SetPermaDoor
function cwPermaDoors:ResetPermaDoor(door, title)
  self.stored[door] = self.stored[door] or {}
  self.stored[door].secret = 'door_no_owner_'..math.random(0, 999999)
  self.stored[door].text = '#Door_Vacant'
  self.stored[door].name = title
  self.stored[door].position = door:GetPos()

  cw.entity:SetDoorUnownable(door, true)
  cw.entity:SetDoorText(door, '#Door_Vacant')
  cw.entity:SetDoorName(door, title)

  self:SavePermaDoors()
end
