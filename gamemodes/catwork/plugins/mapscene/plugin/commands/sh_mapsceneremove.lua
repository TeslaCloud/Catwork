--- Registers the `/MapSceneRemove` admin command, which removes the map scenes within 256 units of the player's eyes.

local COMMAND = cw.command:New('MapSceneRemove')
COMMAND.tip = '#Command_Mapsceneremove_Description'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'a'

--- Removes the map scenes within 256 units of the player's eyes and saves the list.
function COMMAND:OnRun(player, arguments)
  if #cwMapScene.storedList > 0 then
    local position = player:EyePos()
    local removed = 0

    -- Removed backwards so that the list stays free of gaps, which `#` and a random pick rely on.
    for k = #cwMapScene.storedList, 1, -1 do
      if cwMapScene.storedList[k].position:Distance(position) <= 256 then
        table.remove(cwMapScene.storedList, k)

        removed = removed + 1
      end
    end

    if removed > 0 then
      cwMapScene:SaveMapScenes()

      if removed == 1 then
        cw.player:Notify(player, L('MapScene_RemovedOne', removed))
      else
        cw.player:Notify(player, L('MapScene_RemovedMany', removed))
      end
    else
      cw.player:Notify(player, L('MapScene_NoneNear'))
    end
  else
    cw.player:Notify(player, L('MapScene_None'))
  end
end

COMMAND:Register()
