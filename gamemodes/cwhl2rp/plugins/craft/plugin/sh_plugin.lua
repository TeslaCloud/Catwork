--- Entry point of the Craft plugin, which lets players craft items from blueprints at crafting stations.
--
-- Sets the `cwCraft` global alias and defines `cwCraft:PlayerCanCraft` with its checks for materials, tools,
-- attributes, custom requirements and a one second cooldown. The `Craft::CraftItem` netstream looks the blueprint up
-- by ID in `cw.blueprints`, makes sure the player is able to act and still stands at a station of the blueprint's
-- `craftplace` class, runs the checks and crafts it.

PLUGIN:SetGlobalAlias('cwCraft')

util.Include('cl_hooks.lua')
util.Include('sv_hooks.lua')

--- Checks whether a player can craft a blueprint right now.
--
-- Runs the material, tool, attribute and custom requirement checks in that order, then the
-- one second cooldown set after each craft. The first failing check decides the error.
--
-- @param player [Player The player who wants to craft]
-- @param bpTable [Map The blueprint, as returned by `cw.blueprints:FindByID`]
-- @return [Boolean Whether the player can craft it, String Language key of the reason when they cannot]
function cwCraft:PlayerCanCraft(player, bpTable)
  if !self:PlayerHasMaterials(player, bpTable) then
    return false, '#Craft_Error_NoMaterials'
  end

  if !self:PlayerHasTools(player, bpTable) then
    return false, '#Craft_Error_NoTools'
  end

  if !self:PlayerHasAttributes(player, bpTable) then
    return false, '#Craft_Error_NoAttributes'
  end

  if !self:PlayerMeetsRequirements(player, bpTable) then
    return false, '#Craft_Error_NoRequirements'
  end

  if player.cwNextCraftTime and player.cwNextCraftTime > CurTime() then
    return false, '#Craft_Error_Cooldown'
  end

  return true
end

--- Checks whether a player carries every material in a blueprint's recipe.
-- @param player [Player The player to check]
-- @param bpTable [Map The blueprint; its `recipe` list holds `{ itemID, amount }` pairs]
-- @return [Boolean Whether the inventory holds enough of each material]
function cwCraft:PlayerHasMaterials(player, bpTable)
  local materials = bpTable['recipe']

  if materials then
    local inventory = player:GetInventory()

    for k, v in pairs(materials) do
      if cw.inventory:GetItemCountByID(inventory, v[1]) < v[2] then
        return false
      end
    end
  end

  return true
end

--- Checks whether a player carries every tool a blueprint requires.
--
-- Tools are not consumed by crafting.
--
-- @param player [Player The player to check]
-- @param bpTable [Map The blueprint; its `required` list holds `{ itemID, amount }` pairs]
-- @return [Boolean Whether the inventory holds enough of each tool]
function cwCraft:PlayerHasTools(player, bpTable)
  local tools = bpTable['required']

  if tools then
    local inventory = player:GetInventory()

    for k, v in pairs(tools) do
      if cw.inventory:GetItemCountByID(inventory, v[1]) < v[2] then
        return false
      end
    end
  end

  return true
end

--- Checks whether a player meets a blueprint's attribute requirements.
-- @param player [Player The player to check]
-- @param bpTable [Map The blueprint; its `reqatt` list holds `{ attributeID, minimum }` pairs]
-- @return [Boolean Whether every listed attribute is at least its minimum]
function cwCraft:PlayerHasAttributes(player, bpTable)
  local attributes = bpTable['reqatt']

  if attributes then
    for k, v in pairs(attributes) do
      if (cw.attributes:Get(player, v[1], nil, true) or 0) < v[2] then
        return false
      end
    end
  end

  return true
end

--- Checks whether a player passes a blueprint's custom requirement callbacks.
--
-- Each entry of the blueprint's `requirements` list is called with the player and must return
-- `true` to pass; its second return value is the text the craft menu shows for it.
--
-- @param player [Player The player to check]
-- @param bpTable [Map The blueprint]
-- @return [Boolean Whether every callback passed]
function cwCraft:PlayerMeetsRequirements(player, bpTable)
  local requirements = bpTable['requirements']

  if requirements then
    for k, v in pairs(requirements) do
      if v then
        if !v(player) then
          return false
        end
      end
    end
  end

  return true
end

if SERVER then
  netstream.Hook('Craft::CraftItem', function(player, bpTable)
    local curTime = CurTime()

    if player.cwNextCraftAttempt and player.cwNextCraftAttempt > curTime then return end

    player.cwNextCraftAttempt = curTime + 0.25

    -- Never trust a blueprint sent by the client: it only names the blueprint, the recipe is ours.
    local uniqueID = istable(bpTable) and bpTable.uniqueID or bpTable

    bpTable = isstring(uniqueID) and cw.blueprints:GetAll()[uniqueID]

    if !bpTable then return end

    if !player:HasInitialized() or !player:Alive() or player:IsRagdolled() or player:GetNetVar('tied') != 0 then
      return
    end

    -- The menu stays open when its station is left behind, so the station is checked on every craft.
    local station = player.cwCraftStation
    local shootPos = player:GetShootPos()

    if !IsValid(station) or station:GetClass() != bpTable.craftplace
    or station:NearestPoint(shootPos):Distance(shootPos) > 128 then
      cw.player:Notify(player, '#Craft_Error_NoStation')

      return
    end

    local bSucc, err = cwCraft:PlayerCanCraft(player, bpTable)

    if !bSucc then
      cw.player:Notify(player, err)

      return
    end

    cw.core:PrintLog(LOGTYPE_MINOR, player:Name()..' has crafted a '..bpTable['name']..'.')
    cwCraft:PlayerCraftItem(player, bpTable)
    player:EmitSound('plats/elevator_stop.wav')
    player.cwNextCraftTime = curTime + 1

    if bpTable.OnCraft then
      bpTable:OnCraft(player, bpTable)
    end
  end)
end
