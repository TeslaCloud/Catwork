--- Registers the `/SetCharData` superadmin command (aliases `/CharSetData` and `/SetCharacterData`), which sets a
-- character data key on a target player and can only be run by Catwork developers.

local COMMAND = cw.command:New('SetCharData')
COMMAND.tip = '#Command_Setchardata_Description'
COMMAND.text = '#Command_Setchardata_Syntax'
COMMAND.access = 's'
COMMAND.arguments = 2
COMMAND.alias = { 'CharSetData', 'SetCharacterData' }

--- Sets a character data key on the target player; only usable by developers (`catDev:IsDeveloper`).
--
-- The value is converted to the type of the existing value; table and userdata values cannot be set, and a
-- number can only be replaced by a number.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])
  local key = arguments[2] or ''
  local val = arguments[3] or ''

  if catDev and catDev:IsDeveloper(player) then
    if IsValid(target) then
      if isstring(key) and key != '' then
        local existingData = target:GetCharacterData(key)

        if existingData != nil then
          local dataType = type(existingData)

          if dataType == 'string' then
            val = tostring(val)
          elseif dataType == 'number' then
            val = tonumber(val)

            if !val or val != val then
              cw.player:Notify(player, L('Developer_NotANumber'))

              return
            end
          elseif dataType == 'boolean' then
            val = cw.core:ToBool(val)
          elseif dataType == 'table' then
            cw.player:Notify(player, L('Developer_CannotSetTable'))

            return
          else
            cw.player:Notify(player, L('Developer_CannotSetUserData'))

            return
          end

          cw.player:Notify(
            player,
            L('Developer_ModifiedKey').." '"..key.."', "..L('Developer_Value')..' '..tostring(val)..' ('..type(val)..
              '). '..
              L('Developer_OriginalType')..' '..dataType
          )
        else
          cw.player:Notify(
            player,
            L('Developer_CreatedKey').." '"..key.."', "..L('Developer_Value')..' '..tostring(val)..' ('..type(val)..')'
          )
        end

        target:SetCharacterData(key, val)
      else
        cw.player:Notify(player, L('Developer_KeyMustBeString'))
      end
    else
      cw.player:Notify(player, L('NotValidPlayer', arguments[1]))
    end
  else
    cw.player:Notify(player, L('Developer_NotAuthorized'))
  end
end

COMMAND:Register()
