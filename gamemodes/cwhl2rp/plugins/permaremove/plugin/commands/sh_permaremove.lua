local PLUGIN = PLUGIN

local COMMAND = cw.command:New("EntPermaRemove")
COMMAND.tip = "#Command_Entpermaremove_Description"
COMMAND.text = "<none>"
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "s"

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local ent = player:GetEyeTraceNoCursor().Entity

	if (IsValid(ent) and !ent:IsPlayer() and !ent:IsWorld()) then
		local data = {
			class = ent:GetClass(),
			position = ent:GetPos(),
			entity = ent
		}

		PLUGIN.removeData[data.entity] = data
		PLUGIN:SaveRemoves()
		ent:Remove()

		cw.player:Notify(player, L("PermaRemove_Removed"))
	else
		cw.player:Notify(player, L("PermaRemove_NotValidEntity"))
	end
end

COMMAND:Register()
