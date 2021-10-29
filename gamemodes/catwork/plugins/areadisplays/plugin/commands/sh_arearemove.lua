--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("AreaRemove")
COMMAND.tip = "Remove an area by looking near it."
COMMAND.text = "<string Name>"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "s"
COMMAND.arguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local position = player:GetEyeTraceNoCursor().HitPos
	local removed = 0
	local name = string.lower(arguments[1])

	for k, v in pairs(cwAreaDisplays.storedList) do
		if (string.lower(v.name) == name) then
			netstream.Start(nil, "AreaRemove", {
				name = v.name,
				minimum = v.minimum,
				maximum = v.maximum
			})

			cwAreaDisplays.storedList[k] = nil
			removed = removed + 1
		end
	end

	if (removed > 0) then
		if (removed == 1) then
			cw.player:Notify(player, "You have removed "..removed.." area display.")
		else
			cw.player:Notify(player, "You have removed "..removed.." area displays.")
		end
	else
		cw.player:Notify(player, "There were no area displays found with that name.")
	end

	cwAreaDisplays:SaveAreaDisplays()
end

COMMAND:Register();
