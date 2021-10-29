--[[
	© 2016 TeslaCloud Studios.
	Feel free to use, edit or share the plugin, but
	do not re-distribute without the permission of it's author.
--]]

local PLUGIN = PLUGIN

util.Include("sv_plugin.lua")
util.Include("cl_plugin.lua")

-- A function to draw the background blurs.
function cw.core:DrawBackgroundBlurs()
	local scrH, scrW = ScrH(), ScrW()
	local sysTime = SysTime()

	if (!cw.ScreenBlur) then
		cw.ScreenBlur = Material("pp/blurscreen")
	end

	for k, v in pairs(cw.BackgroundBlurs) do
		if (type(k) == "string" or (IsValid(k) and k:IsVisible())) then
			local fraction = math.Clamp((sysTime - v) / 1, 0, 1)
			local x, y = 0, 0

			surface.SetMaterial(cw.ScreenBlur)
			surface.SetDrawColor(255, 255, 255, 255)

			for i = 0.33, 1, 0.33 do
				cw.ScreenBlur:SetFloat("$blur", fraction * 5 * i)
				cw.ScreenBlur:Recompute()
				if (render) then render.UpdateScreenEffectTexture();end
				surface.DrawTexturedRect(x, y, scrW, scrH)
			end

			surface.SetDrawColor(10, 10, 30, 120 * fraction)
			surface.DrawRect(x, y, scrW, scrH)
		end
	end
end