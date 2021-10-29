--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local COMMAND = cw.command:New("CharFollow")
COMMAND.tip = "#Command_Charfollow_Description"

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (Schema.scanners[player]) then
		local scanner = Schema.scanners[player][1]

		if (IsValid(scanner)) then
			local closest

			for k, v in ipairs(_player.GetAll()) do
				if (v:HasInitialized() and !Schema.scanners[v]) then
					if (cw.player:CanSeeEntity(player, v, 0.9, true)) then
						local distance = v:GetPos():Distance(scanner:GetPos())

						if (!closest or distance < closest[2]) then
							closest = {v, distance}
						end
					end
				end
			end

			if (closest) then
				scanner.followTarget = closest[1]

				scanner:Input("SetFollowTarget", closest[1], closest[1], "!activator")

				cw.player:Notify(player, "You are now following "..closest[1]:Name().."!")
			else
				cw.player:Notify(player, "There are no characters near you!")
			end
		end
	else
		cw.player:Notify(player, "You are not a scanner!")
	end
end

COMMAND:Register();
