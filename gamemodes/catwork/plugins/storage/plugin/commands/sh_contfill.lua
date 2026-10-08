--- Registers the `/ContFill` superadmin command, which fills the container the player is looking at with random items
-- to a scale of 1 to 5, optionally from one item category.

local COMMAND = cw.command:New('ContFill')
COMMAND.tip = '#Command_Contfill_Description'
COMMAND.text = '#Command_Contfill_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 's'
COMMAND.arguments = 1
COMMAND.optionalArguments = 1

--- Fills the container the player is looking at with random items.
--
-- The first argument is a scale from 1 to 5 (5 fills it to its full capacity, 1 to a fifth of it); the
-- optional second argument limits the items to categories containing that text.
function COMMAND:OnRun(player, arguments)
  local trace = player:GetEyeTraceNoCursor()
  local scale = tonumber(arguments[1])

  if !scale then
    cw.player:Notify(player, L('Container_NotValidScale'))

    return
  end

  local entity = trace.Entity

  if !IsValid(entity) or !cw.entity:IsPhysicsEntity(entity)
  or !cwStorage.containerList[string.lower(entity:GetModel())] then
    cw.player:Notify(player, L('Container_NotValid'))

    return
  end

  if cwStorage:FillContainer(entity, scale, arguments[2]) then
    cwStorage:SaveStorage()

    cw.player:Notify(player, L('Container_Filled'))
  else
    cw.player:Notify(player, L('Container_CategoryNotExist'))
  end
end

COMMAND:Register()
