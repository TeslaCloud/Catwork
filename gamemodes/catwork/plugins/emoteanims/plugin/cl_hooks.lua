--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

-- Called when the local player should be drawn.
function cwEmoteAnims:ShouldDrawLocalPlayer()
	return self:IsPlayerInStance(cw.client)
end

-- Called when a player's animation is updated.
function cwEmoteAnims:UpdateAnimation(player)
	local stanceAng = player:GetNetVar("StanceAng")

	if (stanceAng) then
		player:SetRenderAngles(stanceAng)
	end
end

-- Called when the calc view table should be adjusted.
function cwEmoteAnims:CalcViewAdjustTable(view)
	if (self:IsPlayerInStance(cw.client) and cw.client:GetNetVar("StanceAng")) then
		local defaultOrigin = view.origin
		local idleStance = cw.client:GetNetVar("StanceIdle")
		local traceLine = nil
		local headBone = "ValveBiped.Bip01_Head1"
		local position = cw.client:EyePos()
		local angles = cw.client:GetNetVar("StanceAng"):Forward()

		if (string.find(cw.client:GetModel(), "vortigaunt")) then
			headBone = "ValveBiped.Head"
		end

		if (idleStance) then
			local bonePosition = cw.client:GetBonePosition(cw.client:LookupBone(headBone))

			if (bonePosition) then
				position = bonePosition + Vector(0, 0, 8)
			end
		end

		if (defaultOrigin) then
			if (idleStance) then
				traceLine = util.TraceLine({
					start = position,
					endpos = position + (angles * 16),
					filter = cw.client
				})
			else
				traceLine = util.TraceLine({
					start = position,
					endpos = position - (angles * 128),
					filter = cw.client
				})
			end

			if (traceLine.Hit) then
				view.origin = traceLine.HitPos + (angles * 4)

				if (view.origin:Distance(position) <= 32) then
					view.origin = defaultOrigin
				end
			else
				view.origin = traceLine.HitPos
			end
		end
	end
end
