--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New('AdvertRemove')
COMMAND.tip = '#Command_Advertremove_Description'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 'a'

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
  local position = player:GetEyeTraceNoCursor().HitPos
  local removed = 0

  for k, v in pairs(cwDynamicAdverts.storedList) do
    if v.position:Distance(position) <= 256 then
      netstream.Start(nil, 'DynamicAdvertRemove', v.position)
        table.remove(cwDynamicAdverts.storedList, k)
      removed = removed + 1
    end
  end

  if removed > 0 then
    if removed == 1 then
      cw.player:Notify(player, L('DynamicAdverts_RemovedOne', removed))
    else
      cw.player:Notify(player, L('DynamicAdverts_RemovedMany', removed))
    end
  else
    cw.player:Notify(player, L('DynamicAdverts_NoneNear'))
  end

  cwDynamicAdverts:SaveDynamicAdverts()
end

COMMAND:Register()
