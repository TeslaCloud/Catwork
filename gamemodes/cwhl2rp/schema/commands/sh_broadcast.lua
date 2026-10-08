--- Registers `/Broadcast`, which lets a character of the administrator faction broadcast a message to the whole city
-- with `Schema:SayBroadcast`.

local COMMAND = cw.command:New('Broadcast')
COMMAND.tip = '#Command_Broadcast_Description'
COMMAND.text = '#Command_Broadcast_Syntax'
COMMAND.flags = bit.bor(CMD_DEFAULT, CMD_FALLENOVER)
COMMAND.arguments = 1

--- Lets an administrator broadcast the joined arguments to everyone with `Schema:SayBroadcast`.
function COMMAND:OnRun(player, arguments)
  if player:GetFaction() == FACTION_ADMIN then
    local text = table.concat(arguments, ' ')

    if text == '' then
      cw.player:Notify(player, L('NotEnoughText'))

      return
    end

    Schema:SayBroadcast(player, text)
  else
    cw.player:Notify(player, L('Err_NotAdministrator'))
  end
end

COMMAND:Register()
