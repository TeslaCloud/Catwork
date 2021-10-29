--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

-- Called to get the screen text info.
function cwPickupObjects:GetScreenTextInfo()
	local blackFadeAlpha = cw.core:GetBlackFadeAlpha()

	if (cw.client:IsRagdolled() and cw.client:GetNetVar("IsDragged")) then
		return {
			alpha = 255 - blackFadeAlpha,
			title = "ВАС ТАЩАТ"
		}
	end
end

-- Called when the local player attempts to get up.
function cwPickupObjects:PlayerCanGetUp()
	local beingDragged = cw.client:GetNetVar("IsDragged") or false

	if (beingDragged) then
		return false
	end
end

timer.Simple(1, function()
	local SWEP = weapons.GetStored("cw_hands")

	if (SWEP) then
		SWEP.Instructions = "Reload: Drop\n"..SWEP.Instructions

		SWEP.Instructions = cw.core:Replace(SWEP.Instructions, "Knock.", "Knock/Pickup.")
		SWEP.Instructions = cw.core:Replace(SWEP.Instructions, "Punch.", "Punch/Throw.")
	end
end);
