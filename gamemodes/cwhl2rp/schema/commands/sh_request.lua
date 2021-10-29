--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("Request")
COMMAND.tip = "#Command_Request_Description"
COMMAND.text = "#Command_Request_Syntax"
COMMAND.flags = bit.bor(CMD_DEFAULT, CMD_DEATHCODE)
COMMAND.arguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local isCityAdmin = (player:GetFaction() == FACTION_ADMIN)
	local isCombine = player:IsCombine()
	local text = table.concat(arguments, " ")

	if (text == "") then
		cw.player:Notify(player, L"You did not specify enough text!")

		return
	end

	if (player:HasItemByID("request_device") or isCombine or isCityAdmin) then
		local curTime = CurTime()

		if (!player.nextRequestTime or isCityAdmin or isCombine or curTime >= player.nextRequestTime) then
			Schema:SayRequest(player, text)

			if (!isCityAdmin and !isCombine) then
				player.nextRequestTime = curTime + 30
			end
		else
			cw.player:Notify(player, "You cannot send a request for another "..math.ceil(player.nextRequestTime - curTime).." second(s)!")
		end
	else
		cw.player:Notify(player, "You do not own a request device!")
	end
end

COMMAND:Register();
