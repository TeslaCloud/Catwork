--- Registers the operator command `/CharSetBiosignalStatus` of the Combine Technology Overlay plugin, which turns the
-- target character's biosignal on or off with `cwCTO:SetPlayerBiosignal`.

local cwCTO = cwCTO

local COMMAND = cw.command:New('CharSetBiosignalStatus')
COMMAND.tip = '#Command_Charsetbiosignalstatus_Description'
COMMAND.text = '#Command_Charsetbiosignalstatus_Syntax'
COMMAND.access = 'o'
COMMAND.flags = CMD_DEFAULT
COMMAND.arguments = 2

--- Turns another character's biosignal on or off with `cwCTO:SetPlayerBiosignal`.
--
-- The arguments are the target's name and a boolean.
function COMMAND:OnRun(player, arguments)
  local ply = _player.Find(arguments[1])

  if !IsValid(ply) then
    cw.player:Notify(player, L('NotValidCharacter', arguments[1]))

    return
  end

  local bEnable = cw.core:ToBool(arguments[2])
  local result = cwCTO:SetPlayerBiosignal(ply, bEnable)

  if result == cwCTO.ERROR_NOT_COMBINE then
    cw.player:Notify(player, L('CTO_CharNotCombine'))
  elseif result == cwCTO.ERROR_ALREADY_ENABLED then
    cw.player:Notify(player, L('CTO_CharBiosignalAlreadyOn'))
  elseif result == cwCTO.ERROR_ALREADY_DISABLED then
    cw.player:Notify(player, L('CTO_CharBiosignalAlreadyOff'))
  end
end

COMMAND:Register()
