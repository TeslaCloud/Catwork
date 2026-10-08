local PLUGIN = PLUGIN

local COMMAND = cw.command:New('EntPermaRemove')
COMMAND.tip = '#Command_Entpermaremove_Description'
COMMAND.text = '<none>'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 's'

--- Removes the entity the player is looking at and saves it so it stays removed after a map restart.
--
-- Players and the world cannot be removed.
function COMMAND:OnRun(player, arguments)
  local ent = player:GetEyeTraceNoCursor().Entity

  if IsValid(ent) and !ent:IsPlayer() and !ent:IsWorld() then
    local data = {
      class = ent:GetClass(),
      position = ent:GetPos(),
      entity = ent
    }

    PLUGIN.removeData[#PLUGIN.removeData + 1] = data
    PLUGIN:SaveRemoves()
    ent:Remove()

    cw.player:Notify(player, L('PermaRemove_Removed'))
  else
    cw.player:Notify(player, L('PermaRemove_NotValidEntity'))
  end
end

COMMAND:Register()
