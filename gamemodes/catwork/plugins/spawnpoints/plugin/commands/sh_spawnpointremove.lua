--- Registers the `/SpawnPointRemove` admin command, which removes the spawn points of a faction, a class or `default`
-- within 256 units of where the player is looking.

local COMMAND = cw.command:New('SpawnPointRemove')
COMMAND.tip = '#Command_Spawnpointremove_Description'
COMMAND.text = '#Command_Spawnpointremove_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'a'
COMMAND.arguments = 1

--- Removes the spawn points of a faction, class or `default` within 256 units of where the player is looking.
function COMMAND:OnRun(player, arguments)
  local faction = faction.FindByID(arguments[1])
  local class = cw.class:FindByID(arguments[1])
  local name = nil

  if class or faction then
    if faction then
      name = faction.name
    else
      name = class.name
    end

    if cwSpawnPoints.spawnPoints[name] then
      local position = player:GetEyeTraceNoCursor().HitPos
      local removed = 0

      local spawnPoints = cwSpawnPoints.spawnPoints[name]

      -- Removed backwards so that the list stays free of gaps, which `#` and a random pick rely on.
      for k = #spawnPoints, 1, -1 do
        if spawnPoints[k].position:Distance(position) <= 256 then
          table.remove(spawnPoints, k)

          removed = removed + 1
        end
      end

      if removed > 0 then
        if removed == 1 then
          cw.player:Notify(player, L('SpawnPoints_RemovedOne', removed, name))
        else
          cw.player:Notify(player, L('SpawnPoints_RemovedMany', removed, name))
        end
      else
        cw.player:Notify(player, L('SpawnPoints_NoneNear', name))
      end
    else
      cw.player:Notify(player, L('SpawnPoints_None', name))
    end

    cwSpawnPoints:SaveSpawnPoints()
  elseif string.lower(arguments[1]) == 'default' then
    if cwSpawnPoints.spawnPoints['default'] then
      local position = player:GetEyeTraceNoCursor().HitPos
      local removed = 0

      local spawnPoints = cwSpawnPoints.spawnPoints['default']

      for k = #spawnPoints, 1, -1 do
        if spawnPoints[k].position:Distance(position) <= 256 then
          table.remove(spawnPoints, k)

          removed = removed + 1
        end
      end

      if removed > 0 then
        if removed == 1 then
          cw.player:Notify(player, L('SpawnPoints_RemovedDefaultOne', removed))
        else
          cw.player:Notify(player, L('SpawnPoints_RemovedDefaultMany', removed))
        end
      else
        cw.player:Notify(player, L('SpawnPoints_NoneNearDefault'))
      end
    else
      cw.player:Notify(player, L('SpawnPoints_NoneDefault'))
    end

    cwSpawnPoints:SaveSpawnPoints()
  else
    cw.player:Notify(player, L('SpawnPoints_NotValidClassOrFaction'))
  end
end

COMMAND:Register()
