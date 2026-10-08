--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

--- Called after Catwork has loaded all of its entities; restores saved cash when the `cash_enabled` config is on.
function cwSaveCash:ClockworkInitPostEntity()
  if config.Get('cash_enabled'):Get() then
    self:LoadCash()
  end
end

--- Called after Catwork saves its data; saves the cash lying on the map.
function cwSaveCash:PostSaveData()
  self:SaveCash()
end
