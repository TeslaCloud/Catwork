--- Registers the `/AdvertRemove` admin command, which removes the adverts within 256 units of where the player is
-- looking.

local COMMAND = cw.command:New('AdvertRemove')
COMMAND.tip = '#Command_Advertremove_Description'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'a'

--- Removes the adverts within 256 units of where the player is looking and saves the list.
function COMMAND:OnRun(player, arguments)
  local position = player:GetEyeTraceNoCursor().HitPos
  local removed = 0

  local storedList = cwDynamicAdverts.storedList

  for k = #storedList, 1, -1 do
    local advertPosition = storedList[k].position

    if advertPosition:Distance(position) <= 256 then
      netstream.Start(nil, 'DynamicAdvertRemove', advertPosition)
      table.remove(storedList, k)

      removed = removed + 1
    end
  end

  if removed > 0 then
    if removed == 1 then
      cw.player:Notify(player, L('DynamicAdverts_RemovedOne', removed))
    else
      cw.player:Notify(player, L('DynamicAdverts_RemovedMany', removed))
    end
  else
    cw.player:Notify(player, L('DynamicAdverts_NoneNear'))
  end

  cwDynamicAdverts:SaveDynamicAdverts()
end

COMMAND:Register()
