--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New('SetCash')
COMMAND.tip = '#Command_Setcash_Description'
COMMAND.text = '#Command_Setcash_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 's'
COMMAND.arguments = 2

--- Sets the target player's cash to an exact amount; arguments are the player name and the amount.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])
  local cash = math.floor(tonumber((arguments[2] or 0)))

  if target then
    if cash and cash >= 1 then
      local playerName = player:Name()
      local targetName = target:Name()
      local giveCash = cash - target:GetCash()

      cw.player:GiveCash(target, giveCash)

      cw.player:Notify(player, L('CashSetPlayer', targetName, '#CashSet_Cash', cw.core:FormatCash(cash, nil, true)))
      cw.player:Notify(target, L('CashSetTarget', '#CashSet_Cash', cw.core:FormatCash(cash, nil, true), playerName))
    else
      cw.player:Notify(player, L('NotValidAmount'))
    end
  else
    cw.player:Notify(player, L('NotValidPlayer', arguments[1]))
  end
end

COMMAND:Register()
