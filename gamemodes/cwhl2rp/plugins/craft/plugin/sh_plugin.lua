--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

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
    for k, v in pairs(materials) do
      local inventory = player:GetInventory()

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
    for k, v in pairs(tools) do
      local inventory = player:GetInventory()

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
      if cw.attributes:Get(player, v[1], nil, true) < v[2] then
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
        local bSucc, text = v(player)

        if !bSucc then
          return false
        end
      end
    end
  end

  return true
end

netstream.Hook('Craft::CraftItem', function(player, bpTable)
  -- Never trust a blueprint sent by the client: it only names the blueprint, the recipe is ours.
  local uniqueID = istable(bpTable) and bpTable.uniqueID or bpTable

  bpTable = isstring(uniqueID) and cw.blueprints:GetAll()[uniqueID]

  if !bpTable then return end

  local bSucc, err = cwCraft:PlayerCanCraft(player, bpTable)

  if !bSucc then
    cw.player:Notify(player, err)

    return false
  end

  cw.core:PrintLog(LOGTYPE_MINOR, player:Name()..' has crafted a '..bpTable['name']..'.')
  cwCraft:PlayerCraftItem(player, bpTable)
  player:EmitSound('plats/elevator_stop.wav')
  player.cwNextCraftTime = CurTime() + 1

  if bpTable.OnCraft then
    bpTable:OnCraft(player, bpTable)
  end
end)
