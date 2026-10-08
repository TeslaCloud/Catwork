--- Server side of the Extra Clothing plugin: the player methods that wear and take off bodygroup and skin clothing, and
-- the hooks that apply its protection.
--
-- `Player:SetBodygroupClothes` and `Player:SetSkinClothes` track the worn items in `player.bgClothesData` and
-- `player.skinClothesData` and send them to the client with the `BGClothes` and `SkinClothes` netstreams.
-- `EntityTakeDamage` reduces non-fall damage by the summed `protection` of the worn items, capped at 60 percent, when
-- the player wears no model-replacing clothes item, and lets `radProtection` clothes block everything but bullets,
-- explosions and falls. The clothing is cleared when the character is unloaded and the bodygroups are reapplied when
-- the player gets up from a ragdoll.
--
-- Originally written for the Global Cooldown community.

local maxArmorValue = 60

local playerMeta = FindMetaTable('Player')

--- Wears or takes off a bodygroup clothing item.
--
-- Calls the item's `OnChangeClothes`, which sets the bodygroup, records the item in
-- `player.bgClothesData` under its bodygroup, adds or subtracts its `protection` from the
-- total and sends the data to the player with the `BGClothes` netstream. Errors in
-- `OnChangeClothes` are printed and do not stop the change.
--
-- @param itemTable [Item The item, based on `bodygroup_base`]
-- @param bShouldUnwear=nil [Boolean `true` to take the item off instead of wearing it]
function playerMeta:SetBodygroupClothes(itemTable, bShouldUnwear)
  if !bShouldUnwear then
    if itemTable.OnChangeClothes then
      local bSuccess, value = pcall(itemTable.OnChangeClothes, itemTable, self, !bShouldUnwear)

      if !bSuccess then
        ErrorNoHalt(value..'\n')
        debug.Trace()
      end
    end

    local clothesData = self.bgClothesData or {}
    local bodygroup = itemTable.bodyGroup
    clothesData[bodygroup] = clothesData[bodygroup] or {}

    if clothesData[bodygroup].itemID then
      local oldItemTable =
        cw.inventory:FindItemByID(self:GetInventory(), clothesData.uniqueID, clothesData.realID) or {}

      if oldItemTable.OnChangeClothes then
        local bSuccess, value = pcall(oldItemTable.OnChangeClothes, oldItemTable, self, bShouldUnwear)

        if !bSuccess then
          ErrorNoHalt(value..'\n')
          debug.Trace()
        end
      end

      clothesData[bodygroup] = {}
    end

    clothesData[bodygroup].val = itemTable.bodyGroupVal
    clothesData[bodygroup].itemID = itemTable.uniqueID..' '..itemTable.itemID
    clothesData[bodygroup].uniqueID = itemTable.uniqueID
    clothesData[bodygroup].realID = itemTable.itemID
    clothesData.plyProtection = (clothesData.plyProtection or 0) + (itemTable.protection or 0)
    netstream.Start(self, 'BGClothes', clothesData)

    self.bgClothesData = clothesData
  else
    if itemTable.OnChangeClothes then
      local bSuccess, value = pcall(itemTable.OnChangeClothes, itemTable, self, !bShouldUnwear)

      if !bSuccess then
        ErrorNoHalt(value..'\n')
        debug.Trace()
      end
    end

    local clothesData = self.bgClothesData or {}
      local bodygroup = itemTable.bodyGroup
      clothesData[bodygroup] = false
      clothesData.plyProtection = (clothesData.plyProtection or 0) - (itemTable.protection or 0)
    netstream.Start(self, 'BGClothes', clothesData)

    self.bgClothesData = clothesData
  end
end

--- Wears or takes off a skin clothing item.
--
-- Calls the item's `OnChangeClothes`, which sets the skin, records the item in
-- `player.skinClothesData` under its skin, adds or subtracts its `protection` from the total
-- and sends the data to the player with the `SkinClothes` netstream.
--
-- @param itemTable [Item The item, based on `skin_base`]
-- @param bShouldUnwear=nil [Boolean `true` to take the item off instead of wearing it]
function playerMeta:SetSkinClothes(itemTable, bShouldUnwear)
  if !bShouldUnwear then
    if itemTable.OnChangeClothes then
      local bSuccess, value = pcall(itemTable.OnChangeClothes, itemTable, self, !bShouldUnwear)

      if !bSuccess then
        ErrorNoHalt(value..'\n')
        debug.Trace()
      end
    end

    local clothesData = self.skinClothesData or {}
      local skin = itemTable.playerSkin
      clothesData[skin] = clothesData[skin] or {}

      if clothesData[skin].itemID then
        local oldItemTable =
          cw.inventory:FindItemByID(self:GetInventory(), clothesData.uniqueID, clothesData.realID) or {}

        if oldItemTable.OnChangeClothes then
          local bSuccess, value = pcall(oldItemTable.OnChangeClothes, oldItemTable, self, bShouldUnwear)

          if !bSuccess then
            ErrorNoHalt(value..'\n')
            debug.Trace()
          end
        end

        clothesData[skin] = {}
      end

      clothesData[skin].val = skin
      clothesData[skin].itemID = itemTable.uniqueID..' '..itemTable.itemID
      clothesData[skin].uniqueID = itemTable.uniqueID
      clothesData[skin].realID = itemTable.itemID
      clothesData.plyProtection = (clothesData.plyProtection or 0) + (itemTable.protection or 0)
    netstream.Start(self, 'SkinClothes', clothesData)

    self.skinClothesData = clothesData
  else
    if itemTable.OnChangeClothes then
      local bSuccess, value = pcall(itemTable.OnChangeClothes, itemTable, self, !bShouldUnwear)

      if !bSuccess then
        ErrorNoHalt(value..'\n')
        debug.Trace()
      end
    end

    local clothesData = self.skinClothesData or {}
      local skin = itemTable.playerSkin
      clothesData[skin] = false
      clothesData.plyProtection = (clothesData.plyProtection or 0) - (itemTable.protection or 0)
    netstream.Start(self, 'SkinClothes', clothesData)

    self.skinClothesData = clothesData
  end
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
      local clothesData = victim.bgClothesData or {}
      local skinClothesData = victim.skinClothesData or {}
      local protection =
        math.Clamp((clothesData.plyProtection or 0) + (skinClothesData.plyProtection or 0), 0, maxArmorValue)

      dmg:ScaleDamage(1 - (protection / 100))
    end
  end
end

--- Called when a player's character is unloaded; clears their bodygroup and skin clothing.
--
-- @param player [Player The player whose character was unloaded]
function PLUGIN:PlayerCharacterUnloaded(player)
  netstream.Start(player, 'BGClothes', nil, true)
  player.bgClothesData = nil

  for i = 0, player:GetNumBodyGroups() - 1 do
    player:SetBodygroup(i, 0)
  end

  netstream.Start(player, 'SkinClothes', nil, true)
  player.skinClothesData = nil

  player:SetSkin(0)
end

--- Called when a player gets up from a ragdoll; reapplies their clothing bodygroups.
--
-- @param player [Player The player who got up]
-- @param state [Number The ragdoll state, a `RAGDOLL_*` value]
-- @param ragdollTable [Map The player's ragdoll data]
function PLUGIN:PlayerUnragdolled(player, state, ragdollTable)
  local bodyGroup = player.bgClothesData
  local skin = player.skinClothesData

  if istable(bodyGroup) then
    for k, v in pairs(bodyGroup) do
      if istable(v) then
        player:SetBodygroup(k, v.val)
      end
    end
  end
end
