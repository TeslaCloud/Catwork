--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("CharTransfer")
COMMAND.tip = "#Command_Chartransfer_Description"
COMMAND.text = "#Command_Chartransfer_Syntax"
COMMAND.access = "o"
COMMAND.arguments = 2
COMMAND.optionalArguments = 1
COMMAND.alias = {"Transfer", "PlyTransfer"}

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = _player.Find(arguments[1])

	if (target) then
		local faction = arguments[2]
		local name = target:Name()

		if (!_faction.GetStored()[faction]) then
			cw.player:Notify(player, faction.." is not a valid faction!")

			return
		end

		--if (!_faction.GetStored()[faction].whitelist or cw.player:IsWhitelisted(target, faction)) then
			local targetFaction = target:GetFaction()

			if (targetFaction == faction) then
				cw.player:Notify(player, target:Name().." is already the "..faction.." faction!")
				return
			end

			if (!_faction.IsGenderValid(faction, target:GetGender())) then
				cw.player:Notify(player, target:Name().." is not the correct gender for the "..faction.." faction!")

				return
			end

			if (!_faction.GetStored()[faction].OnTransferred) then
				cw.player:Notify(player, target:Name().." cannot be transferred to the "..faction.." faction!")

				return
			end

			local bSuccess, fault = _faction.GetStored()[faction]:OnTransferred(target, _faction.GetStored()[targetFaction], arguments[3])

			if (bSuccess != false) then
				target:SetCharacterData("Faction", faction, true)

				cw.player:LoadCharacter(target, cw.player:GetCharacterID(target))
				cw.player:NotifyAll(player:Name().." has transferred "..name.." to the "..faction.." faction.")
			else
				cw.player:Notify(player, fault or target:Name().." could not be transferred to the "..faction.." faction!")
			end
		--else
			--cw.player:Notify(player, target:Name().." is not on the "..faction.." whitelist!")
		--end
	else
		cw.player:Notify(player, arguments[1].." is not a valid player!")
	end
end

COMMAND:Register();
