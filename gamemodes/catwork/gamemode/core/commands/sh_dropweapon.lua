--- Registers the `/DropWeapon` command (alias `/Drop`), which drops the caller's active weapon as an item entity where
-- they are looking.

local COMMAND = cw.command:New('DropWeapon')
COMMAND.tip = '#Command_Dropweapon_Description'
COMMAND.flags = bit.bor(CMD_DEFAULT, CMD_FALLENOVER)
COMMAND.alias = { 'Drop' }
COMMAND.cooldown = 5

--- Drops the caller's active weapon as an item where they are looking; takes no arguments.
--
-- Runs the `PlayerCanDropWeapon` hook first and `PlayerDropWeapon` after.
function COMMAND:OnRun(player, arguments)
  local weapon = player:GetActiveWeapon()

  if IsValid(weapon) then
    local class = weapon:GetClass()
    local itemTable = item.GetByWeapon(weapon)

    if !itemTable then
      cw.player:Notify(player, L('Command_Dropweapon_NotValidWeapon'))
      return
    end

    if hook.Run('PlayerCanDropWeapon', player, itemTable, weapon) then
      local trace = player:GetEyeTraceNoCursor()

      if player:GetShootPos():Distance(trace.HitPos) <= 192 then
        local entity = cw.entity:CreateItem(player, itemTable, trace.HitPos)

        if IsValid(entity) then
          cw.entity:MakeFlushToGround(entity, trace.HitPos, trace.HitNormal)
            player:TakeItem(itemTable, true)
            player:StripWeapon(class)
            player:SelectWeapon('cw_hands')
          hook.Run('PlayerDropWeapon', player, itemTable, entity, weapon)
        end
      else
        cw.player:Notify(player, L('Command_Dropweapon_TooFar'))
      end
    end
  else
    cw.player:Notify(player, L('Command_Dropweapon_NotValidWeapon'))
  end
end

COMMAND:Register()
