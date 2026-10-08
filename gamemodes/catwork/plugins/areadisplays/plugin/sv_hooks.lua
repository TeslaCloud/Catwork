--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

--- Called after Catwork has loaded all map entities; loads the current map's areas.
function cwAreaDisplays:ClockworkInitPostEntity() self:LoadAreaDisplays() end

--- Called when a player's initial data is sent; sends them every stored area.
-- @param player [Player The player receiving the data]
function cwAreaDisplays:PlayerSendDataStreamInfo(player)
  netstream.Start(player, 'AreaDisplays', self.storedList)
end
