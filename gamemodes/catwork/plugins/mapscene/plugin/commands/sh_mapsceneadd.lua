--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New('MapSceneAdd')
COMMAND.tip = '#Command_Mapsceneadd_Description'
COMMAND.text = '#Command_Mapsceneadd_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'a'
COMMAND.optionalArguments = 1

--- Saves the player's eye position and angles as a map scene, optionally spinning.
function COMMAND:OnRun(player, arguments)
  local data = {
    shouldSpin = cw.core:ToBool(arguments[1]),
    position = player:EyePos(),
    angles = player:EyeAngles()
  }

  cwMapScene.storedList[#cwMapScene.storedList + 1] = data
  cwMapScene:SaveMapScenes()

  cw.player:Notify(player, L('MapScene_Added'))
end

COMMAND:Register()
