--- Registers `/Dispatch`, which lets scanners, Overwatch soldiers and senior Civil Protection ranks speak as Dispatch
-- with `Schema:SayDispatch`.

local COMMAND = cw.command:New('Dispatch')
COMMAND.tip = '#Command_Dispatch_Description'
COMMAND.text = '#Command_Dispatch_Syntax'
COMMAND.flags = bit.bor(CMD_DEFAULT, CMD_FALLENOVER)
COMMAND.arguments = 1

--- Lets scanners, Overwatch and senior Civil Protection ranks speak the joined arguments as Dispatch.
function COMMAND:OnRun(player, arguments)
  if player:IsCombine() then
    if Schema:IsPlayerCombineRank(player, { 'SCN', 'OfC', 'EpU', 'DvL', 'CmD', 'SeC' })
    or player:GetFaction() == FACTION_OTA then
      local text = table.concat(arguments, ' ')

      if text == '' then
        cw.player:Notify(player, L('NotEnoughText'))

        return
      end

      Schema:SayDispatch(player, text)
    else
      cw.player:Notify(player, L('CombineRank_TooLowCommand'))
    end
  else
    cw.player:Notify(player, L('Err_NotCombine'))
  end
end

COMMAND:Register()
