--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New('CharUnban')
COMMAND.tip = '#Command_Charunban_Description'
COMMAND.text = '#Command_Charunban_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'a'
COMMAND.arguments = 1

--- Unbans a character by name, online or in the database; the argument is the character name.
function COMMAND:OnRun(player, arguments)
  local charName = string.lower(arguments[1])

  for k, v in ipairs(_player.GetAll()) do
    if v:HasInitialized() then
      if string.lower(v:Name()) == charName then
        cw.player:NotifyAll(L('Command_Charunban_Unbanned', player:Name(), arguments[1]))
        cw.player:SetBanned(player, false)

        return
      else
        for k2, v2 in pairs(v:GetCharacters()) do
          if string.lower(v2.name) == charName then
            cw.player:NotifyAll(L('Command_Charunban_Unbanned', player:Name(), arguments[1]))

            v2.data['CharBanned'] = false

            return
          end
        end
      end
    end
  end

  local charactersTable = 'characters'
  local charName = arguments[1]

  local queryObj = cw.database:Select(charactersTable)
    queryObj:Where('_Name', charName)
    queryObj:Callback(function(result)
      if cw.database:IsResult(result) then
        local queryObj = cw.database:Update(charactersTable)
          queryObj:Where('_Name', charName)
          queryObj:Update('_Data', string.gsub(result[1]._Data or '', '"CharBanned":true', '"CharBanned":false'))
        queryObj:Execute()

        cw.player:NotifyAll(L('Command_Charunban_Unbanned', player:Name(), arguments[1]))
      else
        cw.player:Notify(player, L('NotValidCharacter', charName))
      end
    end)

  queryObj:Execute()
end

COMMAND:Register()
