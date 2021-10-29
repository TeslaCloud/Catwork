--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

--[[ We need the plugin library to add this as a module! --]]
if (!plugin) then
	include("catwork/gamemode/core/libraries/sh_plugin.lua")
end

library.New("outline", cw)

-- A function to add an entity outline.
function cw.outline:Add(entity, glowColor, glowSize, bIgnoreZ)
	if (!glowSize) then glowSize = 2; end

	if (type(entity) != "table") then
		entity = {entity}
	end

	halo.Add(
		entity, glowColor, glowSize, glowSize, 1, true, bIgnoreZ
	)
end

-- A function to add a fading entity outline.
function cw.outline:Fader(entity, glowColor, iDrawDist, bShowAnyway, tIgnoreEnts, glowSize, bIgnoreZ)
	local fOutlineAlpha = glowColor.a

	if (iDrawDist) then
		local distance = cw.client:GetPos():Distance(entity:GetPos())
		fOutlineAlpha = fOutlineAlpha - ((fOutlineAlpha / iDrawDist) * math.min(distance, iDrawDist))
	end

	if (!cw.player:CanSeeEntity(cw.client, entity, 0.9, tIgnoreEnts)
	and !bShowAnyway) then
		fOutlineAlpha = 0
	end

	if (!entity.cwLastOutlineAlpha) then
		entity.cwLastOutlineAlpha = 0
	end

	entity.cwLastOutlineAlpha = math.Approach(
		entity.cwLastOutlineAlpha, fOutlineAlpha, FrameTime() * 64
	)

	if (entity.cwLastOutlineAlpha > 0) then
		self:Add(
			entity, Color(glowColor.r, glowColor.g, glowColor.b, entity.cwLastOutlineAlpha),
			glowSize, bIgnoreZ
		)
	end
end

-- Called when GMod halos should be added.
function cw.outline:PreDrawHalos()
	hook.Run("AddEntityOutlines", self)
end

--[[
	Register the library as a module. We're doing this because
	we want the PreDrawHalos function to be called
	before anything else.
--]]

plugin.Add("Outline", cw.outline);
