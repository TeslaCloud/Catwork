COMMAND = cw.command:New("VortHowl")
COMMAND.tip = "Scream across the city in vortish. Yay."
COMMAND.text = "<string Text>"
COMMAND.arguments = 1
COMMAND.alias = {"vhowl"}

Shouts = {
	Sound("vo/outland_01/intro/ol01_vortcall01.wav"),
	Sound("vo/outland_01/intro/ol01_vortcall02c.wav"),
	Sound("vo/outland_01/intro/ol01_vortresp01.wav"),
	Sound("vo/outland_01/intro/ol01_vortresp04.wav")
}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local faction = player:GetFaction()

	if (faction == FACTION_VORT) then
		netstream.Start(nil, "PlayLocalSound", Shouts[math.random(#Shouts)], player)

		local vorts = {}
		local people = {}

		for k, v in ipairs(_player.GetAll()) do
			if (v:Alive() and v:GetFaction() == FACTION_VORT) then
				table.insert(vorts, v)
			else
				table.insert(people, v)
			end
		end

		chatbox.AddText(vorts, "\""..table.concat(arguments, " ").."\"", {suffix = " shouts in Vortigeese ", sender = player, isPlayerMessage = true, filter = "ic", radius = 99999, textColor = Color(220, 110, 110, 255)})
		chatbox.AddText(people, "shouts something in Vortigeese.", {sender = player, isPlayerMessage = true, filter = "ic", radius = 500, textColor = Color(160, 160, 160, 255)})
	else
		if (!player:IsCombine()) then
			if (faction != FACTION_CWU) then
				if (faction == FACTION_ADMIN) then
					cw.player:Notify(player, "You try to scream on top of your lungs and then you remember that you left the city broadcaster on...")

					Schema:SayBroadcast(player, table.concat(arguments, " "))
				else
					cw.player:Notify(player, "You try to scream on top of your lungs. You get awkward stares from people around you.")
				end
			else
				cw.player:Notify(player, "As you're about to scream on top of your lungs, you remember that you're CWU.")
			end
		else
			cw.player:Notify(player, "You try to scream on top of your lungs. You sound kinda like Darth Vader's 'NOOOOOOOO'.")
		end
	end
end

COMMAND:Register();