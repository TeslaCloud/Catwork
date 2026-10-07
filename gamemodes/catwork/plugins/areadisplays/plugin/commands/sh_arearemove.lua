--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("AreaRemove")
COMMAND.tip = "#Command_Arearemove_Description"
COMMAND.text = "#Command_Arearemove_Syntax"
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
			cw.player:Notify(player, L("AreaDisplays_RemovedOne", removed))
		else
			cw.player:Notify(player, L("AreaDisplays_RemovedMany", removed))
		end
	else
		cw.player:Notify(player, L("AreaDisplays_NoneFound"))
	end

	cwAreaDisplays:SaveAreaDisplays()
end

COMMAND:Register();
