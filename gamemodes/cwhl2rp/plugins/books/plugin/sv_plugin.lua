--- Server-side functions of the Books plugin that pick up, save and restore the placed `cw_book` entities, plus the
-- `TakeBook` netstream handler.
--
-- Books are kept per map in the schema data under `plugins/books/<map>` with their item, owner, position, angles and
-- whether they were frozen.

local PLUGIN = PLUGIN

--- Gives a placed book's item to a player and removes the book, or tells the player why it failed.
--
-- A book can only be taken once, however many requests arrive before the entity is gone.
--
-- @param player [Player The player picking the book up]
-- @param entity [Entity The `cw_book` entity]
function PLUGIN:TakeBook(player, entity)
  if entity.cwTaken or !entity.book then return end

  local success, fault = player:GiveItem(item.CreateInstance(entity.book.uniqueID))

  if !success then
    cw.player:Notify(player, fault)
  else
    entity.cwTaken = true
    entity:Remove()
  end
end

netstream.Hook('TakeBook', function(player, data)
  if !isentity(data) or !IsValid(data) or data:GetClass() != 'cw_book' then return end
  if !player:HasInitialized() or !player:Alive() or player:IsRagdolled() then return end

  local curTime = CurTime()

  if player.cwNextBookTake and player.cwNextBookTake > curTime then return end

  player.cwNextBookTake = curTime + 1

  if player:GetPos():Distance(data:GetPos()) <= 192 and player:GetEyeTraceNoCursor().Entity == data
  and hook.Run('PlayerUse', player, data) then
    PLUGIN:TakeBook(player, data)
  end
end)

--- Spawns the books saved for the current map.
--
-- Restores each book's owner, position and angles, skips books whose item no longer exists
-- and freezes the ones that were frozen when saved.
function PLUGIN:LoadBooks()
  local books = cw.core:RestoreSchemaData('plugins/books/'..game.GetMap())

  for k, v in pairs(books) do
    if item.GetAll()[v.book] then
      local entity = ents.Create('cw_book')

      cw.player:GivePropertyOffline(v.key, v.uniqueID, entity)

      entity:SetAngles(v.angles)
      entity:SetBook(v.book)
      entity:SetPos(v.position)
      entity:Spawn()

      if !v.moveable then
        local physicsObject = entity:GetPhysicsObject()

        if IsValid(physicsObject) then
          physicsObject:EnableMotion(false)
        end
      end
    end
  end
end

--- Saves every `cw_book` on the map to the schema data.
--
-- Writes `plugins/books/<map>` with each book's item, owner, position, angles and whether it
-- can move.
function PLUGIN:SaveBooks()
  local books = {}

  for k, v in ipairs(ents.FindByClass('cw_book')) do
    local physicsObject = v:GetPhysicsObject()
    local moveable

    if IsValid(physicsObject) then
      moveable = physicsObject:IsMoveable()
    end

    if v.book then
      books[#books + 1] = {
        key = cw.entity:QueryProperty(v, 'key'),
        book = v.book.uniqueID,
        angles = v:GetAngles(),
        moveable = moveable,
        uniqueID = cw.entity:QueryProperty(v, 'uniqueID'),
        position = v:GetPos()
      }
    end
  end

  cw.core:SaveSchemaData('plugins/books/'..game.GetMap(), books)
end
