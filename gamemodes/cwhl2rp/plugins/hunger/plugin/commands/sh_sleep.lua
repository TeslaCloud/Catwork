local PLUGIN = PLUGIN

local COMMAND = cw.command:New("Sleep")
COMMAND.tip = "Спокойной ночи."
COMMAND.text = "<none>"
COMMAND.flags = CMD_DEFAULT

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (tonumber(player:GetCharacterData("Fatigue")) >= 30) then
		cw.player:SetRagdollState(player, RAGDOLL_KNOCKEDOUT, 30)
		player:SetCharacterData("Fatigue", 0)
	else
		cw.player:Notify(player, "Вы слишком бодры, чтобы спать!")
	end
end

COMMAND:Register();