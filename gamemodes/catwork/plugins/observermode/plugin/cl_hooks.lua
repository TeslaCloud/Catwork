--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

-- Called to get whether the local player can see the admin ESP.
function cwObserverMode:PlayerCanSeeAdminESP()
	if (!cw.player:IsNoClipping(cw.client)) then
		return false
	end
end

-- Called to get the action text of a player.
function cwObserverMode:GetStatusInfo(player, text)
	if (cw.player:IsNoClipping(player)) then
		table.insert(text, "[Observer]")
	end
end

-- Called when a player attempts to NoClip.
function cwObserverMode:PlayerNoClip(player)
	return false
end
