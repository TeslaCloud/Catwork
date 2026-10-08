--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New('PlyRespawnTP')
COMMAND.tip = '#Command_Plyrespawntp_Description'
COMMAND.text = '#Command_Plyrespawntp_Syntax'
COMMAND.arguments = 1
COMMAND.optionalArguments = 1
COMMAND.access = 'o'
COMMAND.alias = { 'PlyRTP', 'RespawnTP' }

--- Respawns the target player where the caller is looking; the argument is the player name.
function COMMAND:OnRun(player, arguments)
  local target = _player.Find(arguments[1])
  local isSilent = cw.core:ToBool(arguments[2])
  local trace = player:GetEyeTraceNoCursor()

  if target then
    cw.player:LightSpawn(target, true, true, true)
    cw.player:SetSafePosition(target, trace.HitPos)
    cw.player:Notify(player, L('Command_Plyrespawntp_Respawned', target:GetName()))
  else
    cw.player:Notify(player, L('NotValidPlayer', arguments[1]))
  end
end

COMMAND:Register()
