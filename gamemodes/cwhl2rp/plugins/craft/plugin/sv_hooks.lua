--- Server-side functions and hooks of the Craft plugin that carry out a craft and save and load the crafting stations.
--
-- `cwCraft:PlayerCraftItem` takes the recipe's materials, gives the resulting items and progresses attributes.
-- Stations, the entities with `IsCraft` set, are kept per map in the schema data under `plugins/craft/<map>`.

--- Crafts a blueprint for a player without checking whether they may.
--
-- Takes the recipe's materials, gives the resulting items (dropping them in front of the player
-- when the inventory is full), progresses the blueprint's `updatt` attributes and notifies the
-- player. Call `cwCraft:PlayerCanCraft` first.
--
-- @param player [Player The player who crafts]
-- @param bpTable [Map The blueprint to craft]
function cwCraft:PlayerCraftItem(player, bpTable)
  local materials = bpTable['recipe']
  local result = bpTable['finish']
  local updatt = bpTable['updatt']

  if materials then
    for k, v in pairs(materials) do
      for i = 1, v[2] do
        player:TakeItemByID(v[1])
      end
    end
  end

  if result then
    for k, v in pairs(result) do
      for i = 1, v[2] do
        local itemTable = item.CreateInstance(v[1])

        if itemTable and !player:GiveItem(itemTable) then
          local shootPos = player:GetShootPos()
          local trace = util.TraceLine({
            start = shootPos,
            endpos = shootPos + player:GetAimVector() * 64,
            filter = player
          })

          cw.entity:CreateItem(nil, itemTable, trace.HitPos)
        end
      end
    end
  end

  if updatt then
    for k, v in pairs(updatt) do
      player:ProgressAttribute(v[1], v[2], true)
    end
  end

  cw.player:Notify(player, L('Craft_Notify', bpTable['name']))
end

--- Saves the class, position and angles of every crafting station on the map.
--
-- Stations are entities with `IsCraft` set; the data goes to `plugins/craft/<map>`.
function cwCraft:SaveCraftTables()
  local craftTables = {}

  for k, v in ipairs(ents.GetAll()) do
    if v.IsCraft then
      craftTables[#craftTables + 1] = {
        class = v:GetClass(),
        angles = v:GetAngles(),
        position = v:GetPos()
      }
    end
  end

  cw.core:SaveSchemaData('plugins/craft/'..game.GetMap(), craftTables)
end

--- Spawns the crafting stations saved for the current map, frozen in place.
function cwCraft:LoadCraftTables()
  local craftTables = cw.core:RestoreSchemaData('plugins/craft/'..game.GetMap())

  for k, v in pairs(craftTables) do
    local device = ents.Create(v.class)

    if IsValid(device) then
      device:SetPos(v.position)
      device:SetAngles(v.angles)
      device:Spawn()

      local physicsObject = device:GetPhysicsObject()

      if IsValid(physicsObject) then
        physicsObject:EnableMotion(false)
      end
    end
  end
end

--- Called after all map entities have been initialized; loads the saved crafting stations.
function cwCraft:ClockworkInitPostEntity()
  self:LoadCraftTables()
end

--- Called after Catwork saves its data; saves the crafting stations.
function cwCraft:PostSaveData()
  self:SaveCraftTables()
end
