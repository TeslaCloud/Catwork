--- Registers the `/DropCash` command (alias `/DropTokens`), which drops the given amount of the caller's cash as a cash
-- entity where they are looking.

local NAME_CASH = cw.option:GetKey('name_cash')

local COMMAND = cw.command:New('DropCash')
COMMAND.tip = '#Command_Dropcash_Tip'
COMMAND.text = '#Command_Givecash_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.arguments = 1
COMMAND.alias = { 'DropCash', 'DropTokens' }
COMMAND.cooldown = 8

--- Drops the given amount of the caller's cash where they are looking; the argument is the amount.
function COMMAND:OnRun(player, arguments)
  local trace = player:GetEyeTraceNoCursor()
  local cash = tonumber(arguments[1])

  if cash and cash > 1 then
    cash = math.floor(cash)

    if player:GetShootPos():Distance(trace.HitPos) <= 192 then
      if cw.player:CanAfford(player, cash) then
        cw.player:GiveCash(player, -cash, L('Command_Dropcash_Reason'))

        local entity = cw.entity:CreateCash(player, cash, trace.HitPos)

        if IsValid(entity) then
          cw.entity:MakeFlushToGround(entity, trace.HitPos, trace.HitNormal)
        end
      else
        local amount = cash - player:GetCash()
        cw.player:Notify(player, L('YouNeedAnother', cw.core:FormatCash(amount, nil, true)))
      end
    else
      cw.player:Notify(player, L('Command_Dropcash_TooFar'))
    end
  else
    cw.player:Notify(player, L('NotValidAmount'))
  end
end

COMMAND:Register()
