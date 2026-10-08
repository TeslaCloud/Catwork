--- Registers the `/InvAction` command, which runs `destroy`, `drop`, `use` or a custom function on an item instance in
-- the caller's inventory and is what the inventory menu sends.

local COMMAND = cw.command:New('InvAction')
COMMAND.tip = '#Command_Invaction_Description'
COMMAND.text = '#Command_Invaction_Syntax'
COMMAND.flags = bit.bor(CMD_DEFAULT, CMD_FALLENOVER)
COMMAND.arguments = 2
COMMAND.optionalArguments = 1
COMMAND.cooldown = 1

--- Runs an action on an item in the caller's inventory; arguments are the action, item ID and instance ID.
--
-- The action is `destroy`, `drop`, `use` or one of the item's `customFunctions`; any other action fires
-- `PlayerUseUnknownItemFunction`.
function COMMAND:OnRun(player, arguments)
  local itemAction = string.lower(arguments[1])
  itemAction = itemAction:Replace('#', '')
  local itemTable = player:FindItemByID(arguments[2], tonumber(arguments[3]))

  if itemTable then
    local customFunctions = itemTable.customFunctions

    if customFunctions then
      for k, v in pairs(customFunctions) do
        -- An entry is the function's name, or a table that holds it as `name`.
        local name = (istable(v) and v.name) or v

        if isstring(name) and string.lower(name):Replace('#', '') == itemAction then
          if itemTable.OnCustomFunction then
            itemTable:OnCustomFunction(player, name)
            return
          end
        end
      end
    end

    if itemAction == 'destroy' then
      if hook.Run('PlayerCanDestroyItem', player, itemTable) then
        item.Destroy(player, itemTable)
      end
    elseif itemAction == 'drop' then
      local position = player:GetEyeTraceNoCursor().HitPos

      if player:GetShootPos():Distance(position) <= 192 then
        if hook.Run('PlayerCanDropItem', player, itemTable, position) then
          item.Drop(player, itemTable)
        end
      else
        cw.player:Notify(player, L('CantDropFar'))
      end
    elseif itemAction == 'use' then
      if player:InVehicle() and itemTable.useInVehicle == false then
        cw.player:Notify(player, L('Command_Invaction_NoVehicle'))

        return
      end

      if hook.Run('PlayerCanUseItem', player, itemTable) then
        return item.Use(player, itemTable)
      end
    else
      hook.Run('PlayerUseUnknownItemFunction', player, itemTable, itemAction)
    end
  else
    cw.player:Notify(player, L('StoragePlayerNoInstance'))
  end
end

COMMAND:Register()
