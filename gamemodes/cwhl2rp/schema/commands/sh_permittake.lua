--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New('PermitTake')
COMMAND.tip = '#Command_Permittake_Description'
COMMAND.flags = CMD_DEFAULT

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
  if player:IsCombine() then
    if !Schema:IsPlayerCombineRank(player, 'RCT') then
      local target = player:GetEyeTraceNoCursor().Entity

      if target and target:IsPlayer() then
        if target:GetShootPos():Distance(player:GetShootPos()) <= 192 then
          if target:GetFaction() == FACTION_CITIZEN then
            for k, v in pairs(Schema.customPermits) do
              cw.player:TakeFlags(target, v)
            end

            cw.player:Notify(player, L('Permit_Taken'))
          else
            cw.player:Notify(player, L('Err_CharacterNotCitizen'))
          end
        else
          cw.player:Notify(player, L('Err_CharacterTooFar'))
        end
      else
        cw.player:Notify(player, L('Err_MustLookAtCharacter'))
      end
    else
      cw.player:Notify(player, L('CombineRank_TooLowAction'))
    end
  else
    cw.player:Notify(player, L('Err_NotCombine'))
  end
end

COMMAND:Register()
