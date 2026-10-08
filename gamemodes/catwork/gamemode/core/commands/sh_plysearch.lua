--- Registers the superadmin command `/PlySearch`, which opens the target player's inventory and cash for the caller as
-- a `cw.storage` storage.

local COMMAND = cw.command:New('PlySearch')
COMMAND.tip = '#Command_Plysearch_Description'
COMMAND.text = '#Command_Plysearch_Syntax'
COMMAND.access = 's'
COMMAND.arguments = 1

--- Opens the target player's inventory as storage for the caller; the argument is the player name.
--
-- Taking or giving the worn clothing item clears the `clothes` character data.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])

  if target then
    if !target.cwBeingSearched then
      if !player.cwSearching then
        target.cwBeingSearched = true
        player.cwSearching = target

        cw.storage:Open(player, {
          name = target:Name(),
          cash = target:GetCash(),
          weight = target:GetMaxWeight(),
          space = target:GetMaxSpace(),
          entity = target,
          inventory = target:GetInventory(),
          OnClose = function(player, storageTable, entity)
            player.cwSearching = nil

            if IsValid(entity) then
              entity.cwBeingSearched = nil
            end
          end,
          OnTakeItem = function(player, storageTable, itemTable)
            local target = cw.entity:GetPlayer(storageTable.entity)

            if target then
              if target:GetCharacterData('clothes') == itemTable.index then
                if !target:HasItemByID(itemTable.index) then
                  target:SetCharacterData('clothes', nil)

                  if itemTable.OnChangeClothes then
                    itemTable:OnChangeClothes(target, false)
                  end
                end
              end
            end
          end,
          OnGiveItem = function(player, storageTable, itemTable)
            if player:GetCharacterData('clothes') == itemTable.index then
              if !player:HasItemByID(itemTable.index) then
                player:SetCharacterData('clothes', nil)

                if itemTable.OnChangeClothes then
                  itemTable:OnChangeClothes(player, false)
                end
              end
            end
          end
        })
      else
        cw.player:Notify(player, L('Command_Plysearch_AlreadySearching'))
      end
    else
      cw.player:Notify(player, L('Command_Plysearch_BeingSearched', target:Name()))
    end
  else
    cw.player:Notify(player, L('NotValidPlayer', arguments[1]))
  end
end

COMMAND:Register()
