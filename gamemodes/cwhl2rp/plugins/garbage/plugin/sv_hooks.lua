--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

--- Called after Catwork has loaded the map entities; loads the garbage spawn points.
function cwGarbage:ClockworkInitPostEntity()
  self:LoadGarbageSpawnPoints()
end

--- Called every second; spawns garbage at the spawn points whose respawn delay has passed.
--
-- A point only spawns when `CanSpawnGarbage` allows it, then waits for the
-- `garbage_respawn_delay` config before the next pile.
function cwGarbage:OneSecond()
  local curTime = CurTime()

  for k, v in pairs(self.garbagePoints) do
    if v and curTime > v.nextSpawn then
      if hook.Run('CanSpawnGarbage', v.position) then
        self:SpawnGarbage(v)
        v.nextSpawn = curTime + math.Round(config.GetVal('garbage_respawn_delay'))
      end
    end
  end
end

--- Called to check whether garbage can spawn at a point; blocks it within 50 units of another pile.
--
-- @param position [Vector The spawn point's position]
-- @return [Boolean Whether the garbage can spawn]
function cwGarbage:CanSpawnGarbage(position)
  local entities = ents.FindInSphere(position, 50)

  if entities then
    for k, v in ipairs(entities) do
      if IsValid(v) and v:GetClass() == 'cw_garbage' then
        return false
      end
    end
  end

  return true
end

--- Called to get how long a player takes to search garbage.
--
-- The `garbage_pickup_time` config, less a second for every 10 points of Scavenger.
--
-- @param player [Player The player searching]
-- @return [Number The search time in seconds]
function cwGarbage:GetGarbageTime(player)
  return config.GetVal('garbage_pickup_time') - math.Round(
    (cw.attributes:Get(player, ATB_SCAVENGER, nil, true) or 0) / 10
  )
end

--- Called when a player finishes searching garbage; gives them what they found.
--
-- Delays the respawn of the pile's spawn point and picks a random entry from
-- `cwGarbage.stored`. The player finds it when a roll, lowered by their Scavenger attribute,
-- is within the `garbage_item_percentage` config and a second roll is within the entry's
-- chance. Very rare rolls give an RPG, 200 to 1500 cash or ten RPGs instead. Progresses
-- Scavenger by 5.
--
-- @param player [Player The player who searched]
-- @param entity [Entity The `cw_garbage` pile]
function cwGarbage:PlayerTakeGarbage(player, entity)
  for k, v in ipairs(self.garbagePoints) do
    if v.position:Distance(entity:GetPos()) <= 10 then
      v.nextSpawn = CurTime() + math.Round(config.GetVal('garbage_respawn_delay'))
    end
  end

  local chosenEnt = self.stored[math.random(1, #self.stored)]
  local chance = math.random(1, 100) - cw.attributes:Get(player, ATB_SCAVENGER, nil, true)

  local roll, roll2, roll3 = math.random(0, 100), math.random(0, 100), math.random(0, 100)

  if roll == 1 and roll2 == 55 and roll3 == 78 then
    chosenEnt = { 'weapon_rpg', 100 }
  elseif roll == 74 and roll2 == 22 and roll3 == 40 then
    chosenEnt = math.random(200, 1500)
  elseif roll == 33 and roll2 == 78 and roll3 == 0 and math.random(0, 100) == 99 then
    for i = 1, 10 do
      local itemTable = item.CreateInstance('weapon_rpg')

      local success, value = player:GiveItem(itemTable, true)
    end

    cw.player:Notify(player, L('Garbage_Jackpot'))

    return
  end

  if isnumber(chosenEnt) then
    cw.player:GiveCash(player, chosenEnt)
  elseif chance <= config.GetVal('garbage_item_percentage')
  and math.random(0, 100) <= chosenEnt[2] then
    local itemTable = item.CreateInstance(chosenEnt[1])

    local success, value = player:GiveItem(itemTable)

    if success then
      if chosenEnt[1] == 'weapon_rpg' then
        cw.player:Notify(player, L('Garbage_FoundRPG'))

        return
      end

      cw.player:Notify(player, L('Garbage_Found')..' '..itemTable.PrintName)
    else
      cw.player:Notify(player, value)
    end
  else
    cw.player:Notify(player, L('Garbage_FoundNothing'))
  end

  player:ProgressAttribute(ATB_SCAVENGER, 5, true)
end
