--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("PlyTakeFlags")
COMMAND.tip = "#Command_Plytakeflags_Description"
COMMAND.text = "#Command_Plytakeflags_Syntax"
COMMAND.access = "s"
COMMAND.arguments = 2
COMMAND.alias = {"TakeFlags", "RemoveFlags"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])

	if (target) then
		if (string.find(arguments[2], "a") or string.find(arguments[2], "s")
		or string.find(arguments[2], "o")) then
			cw.player:Notify(player, "You cannot take 'o', 'a' or 's' flags!")

			return
		end

		cw.player:TakePlayerFlags(target, arguments[2])

		cw.player:NotifyAll(player:Name().." took '"..arguments[2].."' flags from "..target:SteamName()..".")
	else
		cw.player:Notify(player, L(player, "NotValidCharacter", arguments[1]))
	end
end

COMMAND:Register();
