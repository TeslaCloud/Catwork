local COMMAND = cw.command:New("ContainmentRemove")
COMMAND.tip = ""
COMMAND.text = "#Command_Containmentremove_Syntax"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "s"

function COMMAND:OnRun(player, arguments)
	local position = player:GetEyeTraceNoCursor().HitPos
	local radius = tonumber(arguments[1]) or 64
	local removed = 0

	for k, v in pairs(cwRadSystem.stored) do
		if v.pos then
			if v.pos:Distance(position) <= radius then
				cwRadSystem.stored[k] = nil
				removed = removed + 1
			end
		elseif v.pos1 then
			if v.pos1:Distance(position) <= radius then
				cwRadSystem.stored[k] = nil
				removed = removed + 1
			end
		elseif v.pos2 then
			if v.pos2:Distance(position) <= radius then
				cwRadSystem.stored[k] = nil
				removed = removed + 1
			end
		end
	end

	if removed > 0 then
		cw.player:Notify(player, L("Containment_Removed", removed))
	else
		cw.player:Notify(player, L("Containment_NoneFound"))
	end
end

COMMAND:Register()