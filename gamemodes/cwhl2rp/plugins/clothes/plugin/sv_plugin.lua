--- Server side of the Extra Clothing plugin: the player methods that wear and take off bodygroup and skin clothing, and
-- the hooks that apply its protection.
--
-- `Player:SetBodygroupClothes` and `Player:SetSkinClothes` track the worn items in `player.bgClothesData` and
-- `player.skinClothesData` and send them to the client with the `BGClothes` and `SkinClothes` Cable messages.
-- `EntityTakeDamage` reduces non-fall damage by the summed `protection` of the worn items, capped at 60 percent, when
-- the player wears no model-replacing clothes item, and lets `radProtection` clothes block everything but bullets,
-- explosions and falls. The clothing is cleared when the character is unloaded and reapplied to the model when the
-- player spawns or gets up from a ragdoll.
--
-- Originally written for the Global Cooldown community.

local maxArmorValue = 60

local playerMeta = FindMetaTable('Player')

--- Calls an item's `OnChangeClothes`, printing an error instead of letting it stop the change.
-- @param itemTable [Item The clothing item]
-- @param player [Player The wearer]
-- @param bIsWearing [Boolean Whether the item is being put on]
local function ChangeClothes(itemTable, player, bIsWearing)
  if !itemTable.OnChangeClothes then return end

  local bSuccess, value = pcall(itemTable.OnChangeClothes, itemTable, player, bIsWearing)

  if !bSuccess then
    ErrorNoHalt(tostring(value)..'\n')
    debug.Trace()
  end
end

--- Builds the entry that records a worn item in a clothing data table.
-- @param itemTable [Item The worn item]
-- @param value [Number The bodygroup value or skin the item sets]
-- @return [Map The entry, with `val`, `itemID`, `uniqueID`, `realID` and `protection`]
local function WornEntry(itemTable, value)
  return {
    val = value,
    itemID = itemTable.uniqueID..' '..itemTable.itemID,
    uniqueID = itemTable.uniqueID,
    realID = itemTable.itemID,
    protection = itemTable.protection or 0
  }
end

--- Takes off the item recorded in an entry of a clothing data table, if the player still has it.
-- @param player [Player The wearer]
-- @param worn [Map The entry, as built by `WornEntry`]
local function TakeOffWorn(player, worn)
  local itemTable = cw.inventory:FindItemByID(player:GetInventory(), worn.uniqueID, worn.realID)

  if itemTable then
    ChangeClothes(itemTable, player, false)
  end
end

--- Returns the summed protection of the items recorded in a clothing data table.
-- @param clothesData [Map The clothing data table]
-- @return [Number The total protection]
local function SumProtection(clothesData)
  local protection = 0

  for k, v in pairs(clothesData) do
    if istable(v) then
      protection = protection + (v.protection or 0)
    end
  end

  return protection
end

--- Sets the bodygroups and the skin of the player's worn clothing on their model again.
-- @param player [Player The wearer]
local function ReapplyClothes(player)
  local bodyGroups = player.bgClothesData
  local skins = player.skinClothesData

  if istable(bodyGroups) then
    for k, v in pairs(bodyGroups) do
      if istable(v) then
        player:SetBodygroup(k, v.val)
      end
    end
  end

  if istable(skins) then
    for k, v in pairs(skins) do
      if istable(v) then
        player:SetSkin(v.val)
      end
    end
  end
end

--- Wears or takes off a bodygroup clothing item.
--
-- Calls the item's `OnChangeClothes`, which sets the bodygroup, records the item in
-- `player.bgClothesData` under its bodygroup, updates the total `protection` of the worn
-- items and sends the data to the player with the `BGClothes` Cable message. An item already
-- worn in the same bodygroup is taken off first. Taking off an item that is not the one
-- worn in its bodygroup does nothing. Errors in `OnChangeClothes` are printed and do not
-- stop the change.
--
-- @param itemTable [Item The item, based on `bodygroup_base`]
-- @param bShouldUnwear=nil [Boolean `true` to take the item off instead of wearing it]
function playerMeta:SetBodygroupClothes(itemTable, bShouldUnwear)
  local clothesData = self.bgClothesData or {}
  local bodygroup = itemTable.bodyGroup
  local worn = clothesData[bodygroup]
  local itemID = itemTable.uniqueID..' '..itemTable.itemID

  if bShouldUnwear then
    if !worn or worn.itemID != itemID then return end

    ChangeClothes(itemTable, self, false)
    clothesData[bodygroup] = false
  else
    if worn and worn.itemID != itemID then
      TakeOffWorn(self, worn)
    end

    ChangeClothes(itemTable, self, true)
    clothesData[bodygroup] = WornEntry(itemTable, itemTable.bodyGroupVal)
  end

  clothesData.plyProtection = SumProtection(clothesData)
  cable.send(self, 'BGClothes', clothesData)

  self.bgClothesData = clothesData
end

--- Wears or takes off a skin clothing item.
--
-- Calls the item's `OnChangeClothes`, which sets the skin, records the item in
-- `player.skinClothesData` under its skin, updates the total `protection` and sends the
-- data to the player with the `SkinClothes` Cable message. A model has a single skin, so any
-- other skin item is taken off first. Taking off an item that is not worn does nothing.
--
-- @param itemTable [Item The item, based on `skin_base`]
-- @param bShouldUnwear=nil [Boolean `true` to take the item off instead of wearing it]
function playerMeta:SetSkinClothes(itemTable, bShouldUnwear)
  local clothesData = self.skinClothesData or {}
  local skin = itemTable.playerSkin
  local worn = clothesData[skin]
  local itemID = itemTable.uniqueID..' '..itemTable.itemID

  if bShouldUnwear then
    if !worn or worn.itemID != itemID then return end

    ChangeClothes(itemTable, self, false)
    clothesData[skin] = false
  else
    for k, v in pairs(clothesData) do
      if istable(v) and v.itemID != itemID then
        TakeOffWorn(self, v)
        clothesData[k] = false
      end
    end

    ChangeClothes(itemTable, self, true)
    clothesData[skin] = WornEntry(itemTable, skin)
  end

  clothesData.plyProtection = SumProtection(clothesData)
  cable.send(self, 'SkinClothes', clothesData)

  self.skinClothesData = clothesData
end

--- Called when an entity takes damage; applies clothing protection to players.
--
-- Radiation-proof clothes block all damage but bullets, explosions and falls. Without a
-- clothes item, the summed `protection` of bodygroup and skin clothing, capped at 60,
-- reduces non-fall damage by that percentage.
--
-- @param victim [Entity The damaged entity]
-- @param dmg [CTakeDamageInfo The damage, scaled in place]
function PLUGIN:EntityTakeDamage(victim, dmg)
  if IsValid(victim) and victim:IsPlayer() and !dmg:IsFallDamage() then
    local clothesItem = victim:GetClothesItem()

    if clothesItem and clothesItem.radProtection then
      if !dmg:IsBulletDamage() and !dmg:IsExplosionDamage() then
        dmg:ScaleDamage(0)
      end
    end

    if !clothesItem then
      local clothesData = victim.bgClothesData
      local skinClothesData = victim.skinClothesData
      local protection = math.Clamp(
        (clothesData and clothesData.plyProtection or 0) + (skinClothesData and skinClothesData.plyProtection or 0),
        0,
        maxArmorValue
      )

      if protection > 0 then
        dmg:ScaleDamage(1 - (protection / 100))
      end
    end
  end
end

--- Called when a player's character is unloaded; clears their bodygroup and skin clothing.
--
-- @param player [Player The player whose character was unloaded]
function PLUGIN:PlayerCharacterUnloaded(player)
  cable.send(player, 'BGClothes', nil, true)
  player.bgClothesData = nil

  for i = 0, player:GetNumBodyGroups() - 1 do
    player:SetBodygroup(i, 0)
  end

  cable.send(player, 'SkinClothes', nil, true)
  player.skinClothesData = nil

  player:SetSkin(0)
end

--- Called after a player spawns; reapplies their clothing, as spawning resets the model and skin.
--
-- @param player [Player The player who spawned]
function PLUGIN:PostPlayerSpawn(player)
  ReapplyClothes(player)
end

--- Called when a player gets up from a ragdoll; reapplies their clothing bodygroups and skin.
--
-- @param player [Player The player who got up]
-- @param state [Number The ragdoll state, a `RAGDOLL_*` value]
-- @param ragdollTable [Map The player's ragdoll data]
function PLUGIN:PlayerUnragdolled(player, state, ragdollTable)
  ReapplyClothes(player)
end
