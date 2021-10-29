--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("AdvertRemove")
COMMAND.tip = "Remove a dynamic advert."
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "a"

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local position = player:GetEyeTraceNoCursor().HitPos
	local removed = 0

	for k, v in pairs(cwDynamicAdverts.storedList) do
		if (v.position:Distance(position) <= 256) then
			netstream.Start(nil, "DynamicAdvertRemove", v.position)
				table.remove(cwDynamicAdverts.storedList, k)
			removed = removed + 1
		end
	end

	if (removed > 0) then
		if (removed == 1) then
			cw.player:Notify(player, "You have removed "..removed.." dynamic advert.")
		else
			cw.player:Notify(player, "You have removed "..removed.." dynamic adverts.")
		end
	else
		cw.player:Notify(player, "There were no dynamic adverts near this position.")
	end

	cwDynamicAdverts:SaveDynamicAdverts()
end

COMMAND:Register();
