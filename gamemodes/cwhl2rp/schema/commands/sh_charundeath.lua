--- Registers `/CharUnDeath`, an admin command that undoes the permakill of a character by name.
--
-- A character of an online player has its `permakilled` data cleared in memory; otherwise the flag is rewritten in the
-- `_Data` column of the characters database table (the `mysql_characters_table` config).

local COMMAND = cw.command:New('CharUnDeath')
COMMAND.tip = '#Command_Charundeath_Description'
COMMAND.text = '#Command_Charundeath_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'a'
COMMAND.arguments = 1

--- Undoes the permakill of the character named in the first argument.
--
-- Online players' characters are changed in place; offline characters are changed in the database.
function COMMAND:OnRun(player, arguments)
  local charName = string.lower(arguments[1])

  for k, v in ipairs(_player.GetAll()) do
    if v:HasInitialized() then
      if string.lower(v:Name()) == charName then
        cw.player:NotifyAll(L('PermaKill_Undone', player:Name(), arguments[1]))
        v:SetCharacterData('permakilled', false)
        v:SetNetVar('permaKilled', false)

        return
      else
        for k2, v2 in pairs(v:GetCharacters()) do
          if string.lower(v2.name) == charName then
            cw.player:NotifyAll(L('PermaKill_Undone', player:Name(), arguments[1]))

            v2.data['permakilled'] = false

            return
          end
        end
      end
    end
  end

  local charactersTable = config.Get('mysql_characters_table'):Get()

  charName = arguments[1]

  local queryObj = cw.database:Select(charactersTable)
    queryObj:Where('_Name', charName)
    queryObj:Callback(function(result)
      if cw.database:IsResult(result) then
        local queryObj = cw.database:Update(charactersTable)
          queryObj:Where('_Name', charName)
          queryObj:Update('_Data', string.gsub(result[1]._Data or '', '"permakilled":true', '"permakilled":false'))
        queryObj:Execute()

        cw.player:NotifyAll(L('PermaKill_Undone', player:Name(), arguments[1]))
      else
        cw.player:Notify(player, L('NotValidCharacter', arguments[1]))
      end
    end)

  queryObj:Execute()
end

COMMAND:Register()
