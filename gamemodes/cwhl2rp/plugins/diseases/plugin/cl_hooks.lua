local PLUGIN = PLUGIN;

-- Called when the local player's motion blurs should be adjusted.
function PLUGIN:PlayerAdjustMotionBlurs(motionBlurs)
	if (cw.client:HasInitialized()) then
		local disease = cw.client:GetNetVar("diseases")

		if (disease == "fever") then
			motionBlurs.blurTable["fever"] = 0.25;
		end

		if (disease == "colorblindness") then
			DrawTexturize(1, Material("pp/texturize/plain.png"))
		end

		if (disease == "slow_deathinjection" or disease == "fast_deathinjection") then
			motionBlurs.blurTable["injection"] = 0.1
		end
	end
end