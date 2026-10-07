--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

ITEM.isBaseItem = true
ITEM.name = "Seeds Base"
ITEM.useText = "#Farming_UseText_Plant"
ITEM.category = "#Farming_Category_Plants"
ITEM.weight = 0.01
ITEM.model = "models/props_lab/box01a.mdl"
ITEM.useSound = {
	"player/footsteps/dirt1.wav",
	"player/footsteps/dirt2.wav",
	"player/footsteps/dirt3.wav",
	"player/footsteps/dirt4.wav"
}
ITEM.PlantModel = "models/props/de_inferno/claypot03_damage_01.mdl"
ITEM.PlantName = "#Farming_Plant_Default"
ITEM.GrowTime = { 1200, 1800 }
ITEM.Harvest = {}

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	local trace = player:GetEyeTraceNoCursor()

	if (trace.HitPos:Distance(player:GetShootPos()) <= 192) then
		if ((trace.MatType == MAT_DIRT or trace.MatType == MAT_GRASS) and !IsValid(trace.Entity)) then
			local check = true

			for k, v in pairs(ents.FindInSphere(trace.HitPos, 10)) do
				if (v:GetClass() == "cw_plant") then
					check = false
				end
			end

			if (check) then
				local seed = ents.Create("cw_plant")
				local curTime = CurTime()
				local growtime = math.random(self.GrowTime[1], self.GrowTime[2]) * math.Clamp(
					1 - cw.attributes:Fraction(player, ATB_FARM, 0.25),
					0.6,
					1
				)

				seed:SetPos(trace.HitPos + trace.HitNormal)
				seed:SetItem(self.uniqueID)
				seed:SetGrowTime(curTime + growtime)
				seed:SetSpawnTime(curTime)
				seed:Spawn()
				seed:SetModel(self.PlantModel)

				player:ProgressAttribute(ATB_FARM, 5, true)
				cw.player:Notify(player, L("Farming_Planted"))
			else
				cw.player:Notify(player, L("Farming_TooClose"))
				return false
			end
		else
			cw.player:Notify(player, L("Farming_BadSoil"))
			return false
		end
	else
		cw.player:Notify(player, L("Farming_TooFar"))
		return false
	end
end

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end
