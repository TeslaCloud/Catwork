local cwCTO = cwCTO

local COMMAND = cw.command:New("CameraDisable")
COMMAND.tip = "#Command_Cameradisable_Description"
COMMAND.text = "#Command_Cameradisable_Syntax"
COMMAND.flags = CMD_DEFAULT
COMMAND.arguments = 1

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (player:IsCombine()) then
		if (Schema:IsPlayerCombineRank(player, { "SCN", "OfC", "EpU", "DvL", "SeC" }, true)
		or player:GetFaction() == FACTION_OTA) then
			local camera = Entity(arguments[1])

			if (!IsEntity(camera) or camera:GetClass() != "npc_combine_camera") then
				cw.player:Notify(player, L("CTO_NoCamera"))

				return
			end

			if (camera:GetSequenceName(camera:GetSequence()) != "idlealert") then
				cw.player:Notify(player, L("CTO_CameraNotEnabled"))

				return
			end

			cw.player:Notify(player, L("CTO_DisablingCamera", camera:EntIndex()))

			camera:Fire("Disable")
		else
			cw.player:Notify(player, L("CTO_RankTooLow"))
		end
	else
		cw.player:Notify(player, L("CTO_NotCombine"))
	end
end

COMMAND:Register()
