--- Registers `/ViewObjectives`, which opens the Combine objectives editor for a Combine player by sending
-- `Schema.combineObjectives` with the `EditObjectives` Cable message.

local COMMAND = cw.command:New('ViewObjectives')
COMMAND.tip = '#Command_Viewobjectives_Description'
COMMAND.flags = CMD_DEFAULT

--- Opens the Combine objectives editor for a Combine player; takes no arguments.
function COMMAND:OnRun(player, arguments)
  if player:IsCombine() then
    cable.send(player, 'EditObjectives', Schema.combineObjectives)

    player.editObjectivesAuthorised = true
  else
    cw.player:Notify(player, L('Err_NotCombine'))
  end
end

COMMAND:Register()
