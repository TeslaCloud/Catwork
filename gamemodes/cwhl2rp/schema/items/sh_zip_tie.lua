--- Defines the Zip Tie item for the Metropolice Force and Overwatch factions, which ties up the character the player is
-- looking at after a timed action.
--
-- The target must be untied, within 192 units and facing away or ragdolled. The delay comes from
-- `Schema:GetDexterityTime`; on success `Schema:TiePlayer` is called, the zip tie is used up, agility progresses and
-- a tied Combine unit raises a lost-contact line on the Combine display. The file also adds the item's English and
-- Russian notification strings.

local langEn = cw.lang:GetTable('en')
local langRu = cw.lang:GetTable('ru')

langEn['#Zip_Tie_IsTying'] = 'You are already tying a character!'
langEn['#Zip_Tie_LostContactInformation1'] = 'Downloading lost radio contact information...'
langEn['#Zip_Tie_LostContactInformation2'] = 'WARNING! Radio contact lost for unit at #1 ...'
langEn['#Zip_Tie_IsFacting'] = 'You cannot tie characters that are facing you!'
langEn['#Zip_Tie_IsFarAway'] = 'This character is too far away!'
langEn['#Zip_Tie_IsTied'] = 'This character is already tied!'
langEn['#Zip_Tie_NotValidChar'] = 'That is not a valid character!'
langEn['Tie'] = 'Tie'

langRu['#Zip_Tie_IsTying'] = 'Вы уже связываете персонажа!'
langRu['#Zip_Tie_LostContactInformation1'] = 'Загружается информация о потерянной связи...'
langRu['#Zip_Tie_LostContactInformation2'] = 'ВНИМАНИЕ! Юнит потерял радиосвязь в #1 ...'
langRu['#Zip_Tie_IsFacting'] = 'Вы не можете связать персонажа, который смотрит на вас!'
langRu['#Zip_Tie_IsFarAway'] = 'Этот персонаж слишком далеко!'
langRu['#Zip_Tie_IsTied'] = 'Этот персонаж уже связан'
langRu['#Zip_Tie_NotValidChar'] = 'Вы должны смотреть на персонажа!'
langRu['Tie'] = 'Связать'

ITEM.name = 'Zip Tie'
ITEM.PrintName = '#ITEM_Zip_Tie'
ITEM.cost = 4
ITEM.model = 'models/items/crossbowrounds.mdl'
ITEM.weight = 0.2
ITEM.access = 'v'
ITEM.useText = 'Tie'
ITEM.factions = { FACTION_MPF, FACTION_OTA }
ITEM.business = true
ITEM.uniqueID = 'zip_tie'
ITEM.description = '#ITEM_Zip_Tie_Desc'

--- Starts tying up the player being looked at.
--
-- The target must be untied, within 192 units and facing away or ragdolled. Tying takes
-- `Schema:GetDexterityTime` seconds; on success the target is tied, Combine are alerted when the target
-- is Combine, the zip tie is used up and agility progresses. Nothing happens when the zip tie is gone by
-- then. Always returns `false` so the item is only removed once tying succeeds.
function ITEM:OnUse(player, itemEntity)
  if player.isTying then
    cw.player:Notify(player, L('Zip_Tie_IsTying'))

    return false
  else
    local trace = player:GetEyeTraceNoCursor()
    local target = cw.entity:GetPlayer(trace.Entity)
    local tieTime = Schema:GetDexterityTime(player)

    if target then
      if target:GetNetVar('tied') == 0 then
        if target:GetShootPos():Distance(player:GetShootPos()) <= 192 then
          if target:GetAimVector():Dot(player:GetAimVector()) > 0 or target:IsRagdolled() then
            cw.player:SetAction(player, 'tie', tieTime)

            cw.player:EntityConditionTimer(player, target, trace.Entity, tieTime, 192, function()
              if player:Alive() and !player:IsRagdolled() and target:GetNetVar('tied') == 0
              and (target:GetAimVector():Dot(player:GetAimVector()) > 0 or target:IsRagdolled()) then
                return true
              end
            end, function(success)
              -- The timer also reports failure once the player has left.
              if !IsValid(player) then return end

              player.isTying = nil

              cw.player:SetAction(player, 'tie', false)

              if !success then return end

              -- Used straight off the ground, the zip tie is still that item entity rather than carried.
              local isCarried = player:HasItemInstance(self)
              local entityItem = IsValid(itemEntity) and itemEntity:GetItemTable()

              if !isCarried and (!entityItem or entityItem.itemID != self.itemID) then return end

              Schema:TiePlayer(target, true, nil, player:IsCombine())

              if Schema:PlayerIsCombine(target) then
                local location = Schema:PlayerGetLocation(player)

                Schema:AddCombineDisplayLine(
                  L('Zip_Tie_LostContactInformation1'),
                  Color(255, 255, 255, 255),
                  nil,
                  player
                )
                Schema:AddCombineDisplayLine(
                  L('Zip_Tie_LostContactInformation2', location),
                  Color(255, 0, 0, 255),
                  nil,
                  player
                )
              end

              if isCarried then
                player:TakeItem(self)
              else
                itemEntity:Remove()
              end

              player:ProgressAttribute(ATB_AGILITY, 15, true)
            end)
          else
            cw.player:Notify(player, '#Zip_Tie_IsFacting')

            return false
          end

          player.isTying = true

          cw.player:SetMenuOpen(player, false)

          return false
        else
          cw.player:Notify(player, '#Zip_Tie_IsFarAway')

          return false
        end
      else
        cw.player:Notify(player, '#Zip_Tie_IsTied')

        return false
      end
    else
      cw.player:Notify(player, '#Zip_Tie_NotValidChar')

      return false
    end
  end
end

--- Blocks dropping the zip tie, with a notification, while the player is tying someone.
function ITEM:OnDrop(player, position)
  if player.isTying then
    cw.player:Notify(player, L('Zip_Tie_CantDropWhileTying'))

    return false
  end
end
