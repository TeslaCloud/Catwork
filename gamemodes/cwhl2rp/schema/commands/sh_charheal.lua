--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New('CharHeal')
COMMAND.tip = '#Command_Charheal_Description'
COMMAND.text = '#Command_Charheal_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.arguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
  if player:GetNetVar('tied') == 0 then
    local itemTable = player:FindItemByID(arguments[1])
    local entity = player:GetEyeTraceNoCursor().Entity
    local target = cw.entity:GetPlayer(entity)
    local healed

    if target then
      if entity:GetPos():Distance(player:GetShootPos()) <= 192 then
        if !Schema.scanners[target] then
          if itemTable and arguments[1] == 'health_vial' then
            if player:HasItemByID('health_vial') then
              target:SetHealth(math.Clamp(target:Health() + Schema:GetHealAmount(player, 1.5), 0, target:GetMaxHealth()))
              target:EmitSound('items/medshot4.wav')

              player:TakeItem(itemTable)

              healed = true
            else
              cw.player:Notify(player, L('Heal_NoHealthVial'))
            end
          elseif itemTable and arguments[1] == 'health_kit' then
            if player:HasItemByID('health_kit') then
              target:SetHealth(math.Clamp(target:Health() + Schema:GetHealAmount(player, 2), 0, target:GetMaxHealth()))
              target:EmitSound('items/medshot4.wav')

              player:TakeItem(itemTable)

              healed = true
            else
              cw.player:Notify(player, L('Heal_NoHealthKit'))
            end
          elseif itemTable and arguments[1] == 'bandage' then
            if player:HasItemByID('bandage') then
              target:SetHealth(math.Clamp(target:Health() + Schema:GetHealAmount(player), 0, target:GetMaxHealth()))
              target:EmitSound('items/medshot4.wav')

              player:TakeItem(itemTable)

              healed = true
            else
              cw.player:Notify(player, L('Heal_NoBandage'))
            end
          else
            cw.player:Notify(player, L('Heal_InvalidItem'))
          end

          if healed then
            hook.Run('PlayerHealed', target, player, itemTable)

            player:FakePickup(target)
          end
        elseif itemTable and arguments[1] == 'power_node' then
          if player:HasItemByID('power_node') then
            target:SetHealth(target:GetMaxHealth())
            target:EmitSound('npc/scanner/scanner_electric1.wav')

            player:TakeItem(itemTable)

            Schema:MakePlayerScanner(target, true)
          else
            cw.player:Notify(player, L('Heal_NoPowerNode'))
          end
        else
          cw.player:Notify(player, L('Heal_InvalidItem'))
        end
      else
        cw.player:Notify(player, L('Err_CharacterTooFar'))
      end
    else
      cw.player:Notify(player, L('Err_MustLookAtCharacter'))
    end
  else
    cw.player:Notify(player, L('Err_NoPermissionRightNow'))
  end
end

COMMAND:Register()
