--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

-- Called when Clockwork has loaded all of the entities.
function cwAreaDisplays:ClockworkInitPostEntity() self:LoadAreaDisplays(); end

-- Called when a player's data stream info should be sent.
function cwAreaDisplays:PlayerSendDataStreamInfo(player)
	netstream.Start(player, "AreaDisplays", self.storedList)
end
