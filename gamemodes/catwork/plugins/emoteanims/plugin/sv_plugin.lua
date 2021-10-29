--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

-- A function to make a player exit their stance.
function cwEmoteAnims:MakePlayerExitStance(player, keepPosition)
	if (player.cwPreviousPos and !keepPosition) then
		for k, v in ipairs(_player.GetAll()) do
			if (v != player and v:GetPos():Distance(player.cwPreviousPos) <= 32) then
				cw.player:Notify(player, "Another character is blocking this position!")

				return
			end
		end

		cw.player:SetSafePosition(player, player.cwPreviousPos)
	end

	player:SetForcedAnimation(false)
	player.cwPreviousPos = nil
	player:SetNetVar("StancePos", Vector(0, 0, 0))
	player:SetNetVar("StanceAng", nil)
	player:SetNetVar("StanceIdle", false)
end
