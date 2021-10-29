--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

function cwGarbage:GetProgressBarInfo()
	local action, percentage = cw.player:GetAction(cw.client, true)

	if (!cw.client:IsRagdolled()) then
		if (action == "farming") then
			return {text = "Вы собираете урожай...", percentage = percentage, flash = percentage < 10}
		end
	end
end
