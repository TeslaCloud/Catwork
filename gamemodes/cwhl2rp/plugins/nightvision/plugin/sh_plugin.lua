local PLUGIN = PLUGIN

if CLIENT then
	local render = render

	local coeff = 0.02
	local AlphaAdditive = 1.5
	local AlphaPasses = 1.8
	local Bloom_Multiply = 0.5
	local Bloom_Darken = 0.5
	local Bloom_Blur = 0.1
	local Bloom_ColorMul = 0.25
	local Bloom_Passes = 1
	local CurScale = 0.5
	local DrawNightVision = false
	local oldNight = false
	local matNightVision = CreateMaterial("NightVisionMaterial","UnlitTwoTexture",{
		["$additive"] = "1",
		["$basetexture"] ="_rt_FullFrameFB",
		["$texture2"] = "nightvision_noise",
		["Proxies"] =
		{
			["TextureScroll"] =
			{
				["texturescrollvar"] = "$texture2transform",
				["texturescrollrate"] = "10",
				["texturescrollangle"] = "45"
			}
		}
	})
	matNightVision:SetFloat("$alpha", AlphaAdditive)

	local colorTable = {
		["$pp_colour_addr"] = -1,
		["$pp_colour_addg"] = -0.4,
		["$pp_colour_addb"] = -1,
		["$pp_colour_brightness"] = 0.8,
		["$pp_colour_contrast"]  = 2,
		["$pp_colour_colour"] = 0,
		["$pp_colour_mulr"] = 0 ,
		["$pp_colour_mulg"] = 0.1,
		["$pp_colour_mulb"] = 0
	}

	if render.GetDXLevel() < 80 then
		AlphaPasses = 1
		AlphaAdditive = 0.6
	end

	local function NightVisionFX()
		if oldNight != LocalPlayer():GetNWBool("nightvisionfx") then
			coeff = 0.02
			AlphaAdditive = 1.5
			AlphaPasses = 1.8
			Bloom_Multiply = 0.5
			Bloom_Darken = 0.5
			Bloom_Blur = 0.1
			Bloom_ColorMul = 0.25
			Bloom_Passes = 1
			CurScale = 0.5
			oldNight = LocalPlayer():GetNWBool("nightvisionfx")
		end

		if LocalPlayer():GetNWBool("nightvisionfx") then
			if CurScale < 0.995 then
				CurScale = CurScale + coeff * (1 - CurScale)
			end

			for i = 1, AlphaPasses do
				render.UpdateScreenEffectTexture()
				render.SetMaterial(matNightVision)
				render.DrawScreenQuad()
			end

			colorTable["$pp_colour_brightness"] = CurScale * 0.8
			colorTable["$pp_colour_contrast"] = CurScale * 2
			DrawColorModify(colorTable)
			DrawBloom(Bloom_Darken, CurScale * Bloom_Multiply, Bloom_Blur, Bloom_Blur, Bloom_Passes, CurScale * Bloom_ColorMul, 0, 1, 0)													 -- Blue
		end
	end
	hook.Add("RenderScreenspaceEffects", "NightVisionFX", NightVisionFX)
else
	function PLUGIN:PlayerThink(player, infoTable)
		if (player:GetNWBool("nightvisionfx")) then
			if (!Schema:PlayerCanUseNightvision(player)) then
				player:SetNWBool("nightvisionfx", false)
			end
		end
	end
end

function Schema:PlayerCanUseNightvision(player)
	if player:GetFaction() == FACTION_MPF then
		if self:IsPlayerCombineRank(player, "SpF") then
			return true
		elseif self:IsPlayerCombineRank(player, "CmD") then
			return true
		elseif self:IsPlayerCombineRank(player, "CpT") then
			return true
		elseif self:IsPlayerCombineRank(player, "MaJ") then
			return true
		elseif self:IsPlayerCombineRank(player, "SeC") then
			return true
		end
	end
	if cw.player:HasFlags(player, "9") then
		return true
	end
	return false
end

cw.flag:Add("9", "Nightvision", "Access to the nightvision ability.");