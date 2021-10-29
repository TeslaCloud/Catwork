local cwCTO = cwCTO

local COMMAND = cw.command:New("CameraDisable")
COMMAND.tip = "Remotely disable a Combine camera - IDs are shown on the HUD."
COMMAND.text = "<number CameraID>"
COMMAND.flags = CMD_DEFAULT
COMMAND.arguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (player:IsCombine()) then
		if (Schema:IsPlayerCombineRank(player, {"SCN", "OfC", "EpU", "DvL", "SeC"}, true) or player:GetFaction() == FACTION_OTA) then
			local camera = Entity(arguments[1])

			if (!IsEntity(camera) or camera:GetClass() != "npc_combine_camera") then
				cw.player:Notify(player, "There is no Combine camera with that ID!")

				return
			end

			if (camera:GetSequenceName(camera:GetSequence()) != "idlealert") then
				cw.player:Notify(player, "That camera is not currently enabled.")

				return
			end

			cw.player:Notify(player, "Disabling C-i" .. camera:EntIndex() .. ".")

			camera:Fire("Disable")
		else
			cw.player:Notify(player, "You are not ranked high enough to use this command!")
		end
	else
		cw.player:Notify(player, "You are not the Combine!")
	end
end

COMMAND:Register()