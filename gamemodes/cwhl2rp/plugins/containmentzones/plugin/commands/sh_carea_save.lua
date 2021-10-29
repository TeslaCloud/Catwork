local COMMAND = cw.command:New("ContainmentSave")
COMMAND.tip = ""
COMMAND.text = ""
COMMAND.flags = CMD_DEFAULT
COMMAND.access = "s"
COMMAND.arguments = 0

function COMMAND:OnRun(player, arguments)
	cwRadSystem:SaveAreas()

	cw.player:Notify(player, "You have saved containment areas.")
end

COMMAND:Register()