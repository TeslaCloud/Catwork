--- Registers the `/GiveCash` command (alias `/GiveTokens` and two Russian aliases), which gives some of the caller's
-- cash to the player they are looking at.

local COMMAND = cw.command:New('GiveCash', '')
COMMAND.tip = '#Command_Givecash_Description'
COMMAND.text = '#Command_Givecash_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.arguments = 1
COMMAND.alias = { 'GiveCash', 'GiveTokens', 'ДатьТокены', 'Заплатить' }
COMMAND.cooldown = 5

--- Gives some of the caller's cash to the player they are looking at; the argument is the amount.
--
-- The target must be within 192 units. Unrecognised players are named by their unrecognised name.
function COMMAND:OnRun(player, arguments)
  local target = player:GetEyeTraceNoCursor().Entity
  local cash = math.floor(tonumber(arguments[1]) or 0)

  if target and target:IsPlayer() then
    if target:GetShootPos():Distance(player:GetShootPos()) <= 192 then
      if cash >= 1 then
        if cw.player:CanAfford(player, cash) then
          local playerName = player:Name()
          local targetName = target:Name()

          if !cw.player:DoesRecognise(player, target) then
            targetName = cw.player:GetUnrecognisedName(target, true)
          end

          if !cw.player:DoesRecognise(target, player) then
            playerName = cw.player:GetUnrecognisedName(player, true)
          end

          cw.player:GiveCash(player, -cash)
          cw.player:GiveCash(target, cash)

          cw.player:Notify(player, L('Command_Givecash_Gave', targetName, cw.core:FormatCash(cash, nil, true)))
          cw.player:Notify(target, L('Command_Givecash_Received', playerName, cw.core:FormatCash(cash, nil, true)))
        else
          local amount = cash - player:GetCash()
          cw.player:Notify(player, L('YouNeedAnother', cw.core:FormatCash(amount, nil, true)))
        end
      else
        cw.player:Notify(player, L('NotValidAmount'))
      end
    else
      cw.player:Notify(player, L('Command_Givecash_TooFar'))
    end
  else
    cw.player:Notify(player, L('Command_Givecash_MustLook'))
  end
end

COMMAND:Register()
