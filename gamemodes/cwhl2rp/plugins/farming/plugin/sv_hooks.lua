--- Server-side hooks of the Farming plugin that restore and save plants with the map and hand out the harvest.
--
-- `PlayerHarvest` is fired by `cw_plant` when a player finishes harvesting: a roll helped by the Farming attribute
-- decides whether the player gets the seeds back and how many crops, taken from the seed item's `Harvest` field.

--- Called after all map entities have been initialized; spawns the saved plants.
function PLUGIN:ClockworkInitPostEntity()
  self:LoadPlants()
end

--- Called after Catwork saves its data; saves the plants.
function PLUGIN:PostSaveData()
  self:SavePlants()
end

--- Called when a player finishes harvesting a ripe plant; rolls and gives the harvest.
--
-- The roll is 1 to 100 plus up to 50 from the farming attribute. At 40 or more the player gets
-- the seeds back (twice above 100) and from 50 one to four crops; below 40 the harvest fails.
-- Either way the farming attribute progresses.
--
-- @param player [Player The player who harvested]
-- @param uniqueID [String Unique ID of the seed item the plant grew from; its `Harvest` field
-- lists the seed and crop IDs]
function PLUGIN:PlayerHarvest(player, uniqueID)
  local itemTable = item.FindByID(uniqueID)
  local chance = math.random(1, 100) + math.Round(cw.attributes:Fraction(player, ATB_FARM, 50))

  if chance >= 40 then
    local seed = itemTable.Harvest[1]
    local harvest = itemTable.Harvest[2]

    player:FastGiveItem(seed)

    if chance > 100 then
      player:FastGiveItem(seed)
    end

    if chance >= 50 then
      for i = 1, math.Clamp(math.Round((chance - 50) / 25), 1, 4) do
        player:FastGiveItem(harvest)
      end
    end

    cw.player:Notify(player, L('Farming_HarvestSuccess'))
  else
    cw.player:Notify(player, L('Farming_HarvestFail'))
  end

  player:ProgressAttribute(ATB_FARM, 10, true)
end
