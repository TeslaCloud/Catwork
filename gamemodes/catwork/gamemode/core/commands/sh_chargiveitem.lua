--- Registers the superadmin command `/CharGiveItem` (aliases `/PlyGiveItem`, `/GiveItem`), which gives the target
-- character one to ten instances of an item and requires the `G` flag.

local COMMAND = cw.command:New('CharGiveItem')
COMMAND.tip = '#Command_Chargiveitem_Description'
COMMAND.text = '#Command_Chargiveitem_Syntax'
COMMAND.access = 's'
COMMAND.arguments = 2
COMMAND.optionalArguments = 1
COMMAND.alias = { 'PlyGiveItem', 'GiveItem' }

--- Gives the target character an item; arguments are the character name, the item ID and an optional amount.
--
-- Requires the `G` flag; the amount must be between 1 and 10 and defaults to 1. Both players are notified.
function COMMAND:OnRun(player, arguments)
  if cw.player:HasFlags(player, 'G') then
    local target = _player.Find(arguments[1])
    local amount = math.floor(tonumber(arguments[3]) or 1)

    if target then
      if amount > 0 and amount <= 10 then
        local itemTable = item.FindByID(arguments[2])

        if itemTable and !itemTable.isBaseItem then
          local given = 0

          for i = 1, amount do
            local bSuccess, fault = target:GiveItem(item.CreateInstance(itemTable.uniqueID), true)

            if !bSuccess then
              cw.player:Notify(player, fault)

              break
            end

            given = given + 1
          end

          if given > 1 then
            cw.player:Notify(player, L('Command_Chargiveitem_GaveAmount', target:Name(), given, itemTable.PrintName))
          elseif given == 1 then
            cw.player:Notify(player, L('Command_Chargiveitem_Gave', target:Name(), itemTable.PrintName))
          end

          if player != target then
            if given > 1 then
              cw.player:Notify(
                target,
                L('Command_Chargiveitem_ReceivedAmount', player:Name(), given, itemTable.PrintName)
              )
            elseif given == 1 then
              cw.player:Notify(target, L('Command_Chargiveitem_Received', player:Name(), itemTable.PrintName))
            end
          end
        else
          cw.player:Notify(player, L('GiveInvalidItem'))
        end
      else
        cw.player:Notify(player, L('Command_Chargiveitem_AmountRange'))
      end
    else
      cw.player:Notify(player, L(player, 'NotValidCharacter', arguments[1]))
    end
  else
    cw.player:Notify(player, L('Commands_cwLua_accessDenied', player:Name()))
  end
end

COMMAND:Register()
