--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("PlyGiveFlags")
COMMAND.tip = "#Command_Plygiveflags_Description"
COMMAND.text = "#Command_Plygiveflags_Syntax"
COMMAND.access = "s"
COMMAND.arguments = 2

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])

	if (target) then
		if (string.find(arguments[2], "a") or string.find(arguments[2], "s")
		or string.find(arguments[2], "o")) then
			cw.player:Notify(player, "You cannot give 'o', 'a' or 's' flags!")

			return
		end

		cw.player:GivePlayerFlags(target, arguments[2]);		
		cw.player:NotifyAll(player:Name().." gave "..target:SteamName().." '"..arguments[2].."' flags.")
	else
		cw.player:Notify(player, L(player, "NotValidCharacter", arguments[1]))
	end
end

COMMAND:Register();
