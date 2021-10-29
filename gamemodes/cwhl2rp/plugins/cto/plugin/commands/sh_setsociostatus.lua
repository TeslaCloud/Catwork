local cwCTO = cwCTO

local COMMAND = cw.command:New("SetSocioStatus")
COMMAND.tip = "Update the sociostability status of the city."
COMMAND.text = "<string green|blue|yellow|red|black>"
COMMAND.flags = CMD_DEFAULT
COMMAND.arguments = 1
COMMAND.alias = {"VisorStatus"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (player:IsCombine()) then
		if (Schema:IsPlayerCombineRank( player, {"SCN", "OfC", "EpU", "DvL", "SeC"}, true ) or player:GetFaction() == FACTION_OTA) then
			local tryingFor = string.upper(arguments[1])

			if (!cwCTO.sociostatusColors[tryingFor]) then
				cw.player:Notify(player, "That is not a valid sociostatus!")
			else
				local players = {}

				local pitches = {
					BLUE = 95,
					YELLOW = 90,
					RED = 85,
					BLACK = 80
				}

				local pitch = pitches[tryingFor] or 100

				for k, v in ipairs( _player.GetAll() ) do
					if (Schema:PlayerIsCombine(v) and !v:GetSharedVar("IsBiosignalGone")) then
						players[#players + 1] = v

						timer.Simple(k / 4, function()
							if (IsValid(v)) then
								v:EmitSound("npc/roller/code2.wav", 75, pitch)
							end
						end)
					end
				end

				cwCTO.socioStatus = tryingFor

				Schema:AddCombineDisplayLine("ALERT! Sociostatus updated to " .. tryingFor .. "!", cwCTO.sociostatusColors[tryingFor])

				netstream.Start(players, "RecalculateHUDObjectives", {cwCTO.socioStatus, Schema.combineObjectives})
			end
		else
			cw.player:Notify(player, "You are not ranked high enough to use this command!")
		end
	else
		cw.player:Notify(player, "You are not the Combine!")
	end
end

COMMAND:Register()