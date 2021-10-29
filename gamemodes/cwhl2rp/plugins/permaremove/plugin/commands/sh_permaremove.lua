local PLUGIN = PLUGIN

local COMMAND = cw.command:New("EntPermaRemove")
COMMAND.tip = "Permanently Remove an entity. (Warning! Be super careful with this.)"
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

		cw.player:Notify(player, "This entity will no longer spawn.")
	else
		cw.player:Notify(player, "This is not a valid entity!")
	end
end

COMMAND:Register();
