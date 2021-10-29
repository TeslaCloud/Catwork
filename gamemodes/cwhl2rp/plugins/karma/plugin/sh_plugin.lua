--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

PLUGIN:SetGlobalAlias("cwKarma")

cw.flag:Add("k", "Karma Manipulation", "Access to karma commands.")

local stored = cwKarma.stored or {}
cwKarma.stored = stored

function cwKarma:AddKarmaLevel(bottom, ceiling, phrase)
	if (!bottom or !ceiling or !phrase) then return end

	table.insert(stored, {phrase = phrase, bottom = bottom, ceiling = ceiling})
end

cwKarma:AddKarmaLevel(-100, -90, "#Karma_Monster")
cwKarma:AddKarmaLevel(-89, -70, "#Karma_Evil")
cwKarma:AddKarmaLevel(-69, -40, "#Karma_Criminal")
cwKarma:AddKarmaLevel(-39, -10, "#Karma_Hooligan")
cwKarma:AddKarmaLevel(-9, 9, "#Karma_Neutral")
cwKarma:AddKarmaLevel(10, 39, "#Karma_Decent")
cwKarma:AddKarmaLevel(40, 69, "#Karma_Kind")
cwKarma:AddKarmaLevel(70, 89, "#Karma_GoodSamaritan")
cwKarma:AddKarmaLevel(90, 100, "#Karma_Divine")

do
	local playerMeta = FindMetaTable("Player")

	function playerMeta:GetKarma()
		return self:GetCharacterData("karma", self:GetNetVar("karma", 0))
	end

	function playerMeta:GetKarmaLevel()
		local karma = self:GetKarma()

		if (player.cachedKarma != karma) then
			player.cachedKarma = karma
			player.cachedKarmaString = "Error"

			for k, v in ipairs(stored) do
				if (karma >= v.bottom and karma <= v.ceiling) then
					player.cachedKarmaString = v.phrase

					break
				end
			end
		else
			return player.cachedKarmaString
		end
	end

	function playerMeta:SetKarma(karma)
		local oldKarma = self:GetCharacterData("karma")
		local diff = oldKarma - tonumber(karma)
		local color

		karma = math.Clamp(karma, -100, 100)

		if (diff > 0) then
			color = Color(255, 0, 0, 100)
		else
			color = Color(0, 0, 255, 100)
		end

		self:ScreenFade(1, color, 1, .4)
		self:SetCharacterData("karma", karma)
		self:SetNetVar("karma", karma)
	end
end

util.Include("cl_hooks.lua")
util.Include("sv_hooks.lua")
