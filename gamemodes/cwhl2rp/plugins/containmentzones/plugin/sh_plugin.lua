local PLUGIN = PLUGIN

PLUGIN:SetGlobalAlias("cwRadSystem")

cw.player:AddCharacterData("radlevel", NWTYPE_NUMBER, 0, true)
cw.player:AddCharacterData("radresist", NWTYPE_NUMBER, 0, true)
cw.player:AddCharacterData("cp_filter", NWTYPE_NUMBER, 0, true)

if (SERVER) then
	cwRadSystem.stored = cwRadSystem.stored or {}

	function cwRadSystem:PlayerRestoreCharacterData(ply, data)
		if !data["radlevel"] then
			data["radlevel"] = 0
		end
		if !data["radresist"] then
			data["radresist"] = 0
		end
		if !data["cp_filter"] then
			if ply:GetFaction() == FACTION_MPF then
				data["cp_filter"] = 100
			else
				data["cp_filter"] = 0
			end
		end
	end

	function cwRadSystem:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
		if !firstSpawn and !lightSpawn then
			player:SetCharacterData("radlevel", 0)
			player:SetCharacterData("radresist", 0)

			if player:GetFaction() == FACTION_MPF then
				player:SetCharacterData("cp_filter", 100)
			else
				player:SetCharacterData("cp_filter", 0)
			end
		end
	end

	local function checkRadSphere(pos, radius, rad)
		for k, v in pairs(ents.FindInSphere(pos, radius)) do
			if !v:IsPlayer() then continue end

			v:SetNWBool("inRadArea", true)
			v.inRadArea = CurTime() + 1
			v.radEffects[#v.radEffects + 1] = rad
		end
	end

	local function checkRadBox(pos1, pos2, rad)
		for k, v in pairs(ents.FindInBox(pos1, pos2)) do
			if !v:IsPlayer() then continue end

			v:SetNWBool("inRadArea", true)
			v.inRadArea = CurTime() + 1
			v.radEffects[#v.radEffects + 1] = rad
		end
	end

	function cwRadSystem:HalfSecond()
		for k, v in pairs(player.GetAll()) do
			v.radEffects = {}
			v:SetNWBool("inRadArea", false)
		end

		for k, zone in pairs(self.stored) do
			if zone.pos then
				checkRadSphere(zone.pos, zone.radius, zone.rad)
			end
			if zone.pos1 then
				if zone.pos2 then
					checkRadBox(zone.pos1, zone.pos2, zone.rad)
				end
			end
		end

		for k, v in pairs(player.GetAll()) do
			if !v:Alive() then continue end
			if v.inRadArea and v.inRadArea >= CurTime() then
				hook.Run("OnPlayerInContainmentArea", v, math.max(0,unpack(v.radEffects)))
			end
		end
	end

	function cwRadSystem:ModifyPlayerRadResistance(ply, rad, radresist)
		local clothesItem = ply:GetClothesItem()

		if (clothesItem and clothesItem.radProtection) then
			radresist = radresist + 100
		end

		if ply:GetFaction() == FACTION_OTA then
			radresist = radresist + 98
		elseif ((ply:GetFaction() == FACTION_VORT) or (ply:GetFaction() == FACTION_VORT_SLAVE)) then
			radresist = radresist + 100
		elseif ply:GetFaction() == FACTION_MPF then
			radresist = radresist + 5

			local energy = ply:GetCharacterData("cp_filter", 0)
			local value = math.abs(math.max(0.075, rad * 0.025))
			local newenergy = math.Clamp(energy - value, 0, 100)

			if energy > 0 then
				radresist = radresist + 93
			end

			ply:SetCharacterData("cp_filter", newenergy)
			ply:SetNWInt("resist_rad", newenergy)
		else
			local gasmasks = ply:GetInventory()["gasmask"]
			if gasmasks then
				local gasmask_equipped

				for k, gasmask in pairs(gasmasks) do
					if !gasmask:GetData("equip") then continue end
					gasmask_equipped = gasmask
				end
				if gasmask_equipped then
					local energy = gasmask_equipped:GetData("energy")
					local value = math.abs(math.max(0.3, rad * 0.2))
					local newenergy = math.Clamp(energy - value, 0, 100)

					radresist = radresist + 5
					if energy > 0 then
						radresist = radresist + 93
					end

					gasmask_equipped:SetData("energy", newenergy)
					ply:SetNWInt("resist_rad", newenergy)
				else
					if ply:GetNWInt("resist_rad") != 0 then
						ply:SetNWInt("resist_rad", 0)
					end
				end
			end
		end
		if self:PlayerIsMechanic(ply) then
			radresist = radresist + 50
		end

		return radresist
	end

	function cwRadSystem:OnPlayerInContainmentArea(ply, rad)
		if !ply.nextRadDamage then ply.nextRadDamage = CurTime() + 1 end
		if ply.nextRadDamage and CurTime() >= ply.nextRadDamage then
			local radlevel = ply:GetCharacterData("radlevel", 0)
			local radresist = ply:GetCharacterData("radresist", 0)

			ply:SetNWInt("radLevel", rad)

			radresist = hook.Run("ModifyPlayerRadResistance", ply, rad, radresist)
			rad = math.Round(rad + ((rad/100)*(radresist - (radresist*2))),2)

			if rad < 0 then
				rad = 0
			end

			ply:SetNWInt("radLevelRes", rad)
			ply:SetCharacterData("radlevel", radlevel + rad)

			ply.nextRadDamage = CurTime() + 1
		end
	end
	function cwRadSystem:PlayerThink(player, curTime, infoTable)
		local radlevel = player:GetCharacterData("radlevel", 0)

		if player:Alive() then
			if player:GetCharacter() then
				if radlevel then
					if player.prevRadLevel != radlevel then
						hook.Run("OnPlayerRadLevelChanged", player, radlevel)
						player.prevRadLevel = radlevel
					end
					hook.Run("PlayerRadThink", player, radlevel)
				end
			end
		end
	end
	function cwRadSystem:PlayerDeath(ply)
		ply:SetNWBool("inRadArea", false)
		ply:SetCharacterData("radlevel", 0)
		ply:SetNWInt("radLevel", 0)
		ply:SetNWInt("radLevelRes", 0)
		ply:SetNWInt("resist_rad", 0)
		ply.nextRadDamage = nil
		ply.nextRadApply = nil
		ply.lastRadMessageTime = nil
		ply.lastRadMessage = nil
	end
	function cwRadSystem:PlayerRadThink(ply, newrad)
		if newrad > 999 then
			if !ply.nextRadApply then ply.nextRadApply = CurTime() + 0.5 end
			if CurTime() >= ply.nextRadApply then
				ply:TakeDamage((ply:Health()/(newrad/ply:GetMaxHealth())), ply, ply)
				ply.nextRadApply = CurTime() + 0.5
			end
		elseif newrad > 899 then
			if !ply.nextRadFall then ply.nextRadFall = CurTime() + 20 end
			if !ply:IsRagdolled() and !ply:IsNoClipping() then
				if CurTime() >= ply.nextRadFall then
					if 4 > math.random(1, 1000) then
						cw.player:SetRagdollState(ply, RAGDOLL_KNOCKEDOUT, math.random(5, 15))
						cw.chatBox:Add(ply, nil, "sleep", "** Вы сильно устали, и Вам очень плохо. Вы ощущаете жар по всему телу...")
						ply.nextRadFall = CurTime() + 20
					end
				end
			end
		end
	end
	function cwRadSystem:RadMessage(ply, text)
		if !ply.lastRadMessageTime then ply.lastRadMessageTime = CurTime() end
		if ply.lastRadMessageTime and CurTime() >= ply.lastRadMessageTime then
			--cw.chatBox:Add(ply, nil, "sleep", "** " .. text)
			chatbox.AddText(ply, text, {textColor = Color("#89D235"), filter = "player_events", icon = false})
			if ply.lastRadMessage != text then
				ply.lastRadMessageTime = CurTime() + math.random(59,257)
			end
		end
	end
	function cwRadSystem:OnPlayerRadLevelChanged(ply, newrad)
		if self:PlayerHasRadImmune(ply) then
			return
		end

		if newrad > 899 then
			ply:BoostAttribute("Radiation", ATB_ACROBATICS, -60)
			ply:BoostAttribute("Radiation", ATB_ENDURANCE, -60)
			ply:BoostAttribute("Radiation", ATB_STRENGTH, -60)
			ply:BoostAttribute("Radiation", ATB_AGILITY, -60)
			ply:BoostAttribute("Radiation", ATB_DEXTERITY, -60)
			ply:BoostAttribute("Radiation", ATB_STAMINA, -60)
			self:RadMessage(ply, "У Вас внутреннее кровотечение. Кроме того, у Вас вздутие живота и жуткая агония.")
		elseif newrad > 599 then
			ply:BoostAttribute("Radiation", ATB_ACROBATICS, -15)
			ply:BoostAttribute("Radiation", ATB_ENDURANCE, -30)
			ply:BoostAttribute("Radiation", ATB_STRENGTH, -30)
			ply:BoostAttribute("Radiation", ATB_AGILITY, -30)
			ply:BoostAttribute("Radiation", ATB_DEXTERITY, -30)
			ply:BoostAttribute("Radiation", ATB_STAMINA, -30)
			self:RadMessage(ply, "У Вас сильное и продолжительное кровотечение. Вас рвет кровью.")
		elseif newrad > 449 then
			ply:BoostAttribute("Radiation", ATB_ACROBATICS, -10)
			ply:BoostAttribute("Radiation", ATB_ENDURANCE, -30)
			ply:BoostAttribute("Radiation", ATB_STRENGTH, -10)
			ply:BoostAttribute("Radiation", ATB_AGILITY, -15)
			ply:BoostAttribute("Radiation", ATB_DEXTERITY, -15)
			ply:BoostAttribute("Radiation", ATB_STAMINA, -20)
			self:RadMessage(ply, "У Вас очень сильное кровотечение. Вам ужасно плохо, и у Вас выпадают волосы.")
		elseif newrad > 299 then
			ply:BoostAttribute("Radiation", ATB_ACROBATICS, -2)
			ply:BoostAttribute("Radiation", ATB_ENDURANCE, -3)
			ply:BoostAttribute("Radiation", ATB_STRENGTH, -5)
			ply:BoostAttribute("Radiation", ATB_AGILITY, -10)
			ply:BoostAttribute("Radiation", ATB_DEXTERITY, -10)
			ply:BoostAttribute("Radiation", ATB_STAMINA, -10)
			self:RadMessage(ply, "Вы чувствуете сильную усталость, рвота не прекращается, и время вашего выздоровления увеличивается.")
		elseif newrad > 149 then
			ply:BoostAttribute("Radiation", ATB_ACROBATICS, -1)
			ply:BoostAttribute("Radiation", ATB_ENDURANCE, -2)
			ply:BoostAttribute("Radiation", ATB_STRENGTH, -2)
			ply:BoostAttribute("Radiation", ATB_AGILITY, -5)
			ply:BoostAttribute("Radiation", ATB_DEXTERITY, -2)
			ply:BoostAttribute("Radiation", ATB_STAMINA, -2)
			self:RadMessage(ply, "Вас сильно тошнит. После того, как Вас вырвало, Вы чувствуете легкую усталость.")
		else
			ply:BoostAttribute("Radiation", ATB_ACROBATICS, false)
			ply:BoostAttribute("Radiation", ATB_ENDURANCE, false)
			ply:BoostAttribute("Radiation", ATB_STRENGTH, false)
			ply:BoostAttribute("Radiation", ATB_AGILITY, false)
			ply:BoostAttribute("Radiation", ATB_DEXTERITY, false)
			ply:BoostAttribute("Radiation", ATB_STAMINA, false)
		end
	end
	function cwRadSystem:PlayerShouldStaminaRegenerate(player)
		if !self:PlayerHasRadImmune(player) then
			local rad = player:GetCharacterData("radlevel", 0)
			if rad > 199 then
				return falseн
			end
		end
	end

	function cwRadSystem:SaveAreas()
		local areas = {}

		for k, v in pairs(self.stored) do
			areas[#areas + 1] = {
				rad = v.rad,
				pos = v.pos,
				pos1 = v.pos1,
				pos2 = v.pos2,
				radius = v.radius
			}
		end

		cw.core:SaveSchemaData("plugins/containment/"..game.GetMap(), areas)
	end

	function cwRadSystem:ClockworkInitPostEntity()
		local areas = cw.core:RestoreSchemaData("plugins/containment/"..game.GetMap())

		for k, v in pairs(areas) do
			self.stored[#self.stored + 1] = {
				rad = tonumber(v.rad),
				pos = v.pos,
				pos1 = v.pos1,
				pos2 = v.pos2,
				radius = tonumber(v.radius)
			}
		end
	end

	function cwRadSystem:PostSaveData()
		self:SaveAreas()
	end

	concommand.Add("cwradsys_get", function(ply)
		if ply:IsSuperAdmin() then
			netstream.Start(ply, "cwRadSystemDataClear", {})
			for k, v in pairs(self.stored) do
				netstream.Start(ply, "cwRadSystemData", { pos = v.pos, pos1 = v.pos1, pos2 = v.pos2, radius = v.radius, rad = v.rad})
			end
		end
	end)
else
	cwRadSystem.localstored = cwRadSystem.localstored or {}
	cwRadSystem.show = false

	function cwRadSystem:RenderScreenspaceEffects()
		local LP = cw.client
		local CT = UnPredictedCurTime()
		if self:PlayerHasRadImmune(LP) then
			return
		end

		if Schema:PlayerIsCombine(LP) then
			if LP:GetFaction() == FACTION_OTA then
				if Schema.combineOverlay:GetFloat("$alpha") != 1 then
					Schema.combineOverlay:SetFloat("$alpha", 1)
				end
			else
				if Schema.combineOverlay:GetFloat("$alpha") != 0.4 then
					Schema.combineOverlay:SetFloat("$alpha", 0.4)
				end
			end

			DrawMaterialOverlay("effects/combine_binocoverlay",0)
		end

		local rad = LP:GetCharacterData("radlevel", 0) or 0
		if rad > 449 then
			local raddelta = LP:GetCharacterData("radlevel", 0)/(1000+449)
			local mod = (0.5 * raddelta) * (LP:GetMaxHealth()/LP:Health())
			local sinScaler = math.sin(CT * mod)
			DrawBloom(0,5 * mod, sinScaler * math.Rand(-5,5), sinScaler * math.Rand(-5,5),6 * mod,1,(1* math.Clamp(math.abs(sinScaler),1,100) + math.abs(math.cos(CT))) * mod,0,0)
		end
		--if rad > 299 then
		--	local raddelta = LP:GetCharacterData("radlevel", 0)/(1000+299)
		--	DrawMotionBlur(0.4, 1 * raddelta, 0)
		---end
	end

	function cwRadSystem:GeigerThink()
		local LP = cw.client
		local highsound = false
		local pct = 0
		local flvol = 0
		local radlevel = LP:GetNWInt("radLevel") or 0

		if !self.LastSound then self.LastSound = CurTime() end
		if (CurTime() - self.LastSound) < 0.06 then return end
		self.LastSound = CurTime()

		if LP:GetNWBool("inRadArea") then
			if radlevel > 199 then
				pct = 90
				flvol = 0.475
				highsound = true
			elseif radlevel > 140 then
				pct = 80
				flvol = 0.45
				highsound = true
			elseif radlevel > 90 then
				pct = 60
				flvol = 0.425
				highsound = true
			elseif radlevel > 49 then
				pct = 40
				flvol = 0.4
				highsound = true
			elseif radlevel > 24 then
				pct = 28
				flvol = 0.39
				highsound = true
			elseif radlevel > 19 then
				pct = 8
				flvol = 0.35
				highsound = true
			elseif radlevel > 9 then
				pct = 8
				flvol = 0.3
				highsound = false
			elseif radlevel > 5 then
				pct = 4
				flvol = 0.25
				highsound = false
			elseif radlevel > 0 then
				pct = 2
				flvol = 0.2
				highsound = false
			else
				pct = 0
				flvol = 0
				highsound = false
			end
			flvol = (flvol * (math.random(0,127)) / 255) + 0.25

			if math.random(0,127) < pct then
				local snd = "player/geiger"..math.random(1,2)..".wav"
				if highsound then
					snd = "player/geiger"..math.random(2,3)..".wav"
				end

				LP:EmitSound(snd, 80, math.random(90, 110), flvol)
			end
		end
	end
	function cwRadSystem:Think()
		local LP = cw.client

		if self:PlayerHasGeigerCounter(LP) then
			self:GeigerThink()
		end
	end

	function cwRadSystem:GetBars(bars)
		local LP = cw.client
		local cp_filter = LP:GetCharacterData("cp_filter") or 0

		if LP:GetFaction() == FACTION_MPF then
			local delta = math.floor(cp_filter)
			cw.bars:Add("ФИЛЬТР", Color(130,130,130), nil, cp_filter, 100, cp_filter < 90)
		end
	end

	function cwRadSystem:HUDPaint()
		local LocalPlayer = LocalPlayer()
		local hasgeiger = self:PlayerHasGeigerCounter(LocalPlayer)
		local resist = ""
		local radzonelevel = math.Round(LocalPlayer:GetNWInt("radLevel"), 1) or 0
		local radzonelevel2 = math.Round(LocalPlayer:GetNWInt("radLevelRes"), 1) or 0

		if radzonelevel2 != radzonelevel then
			resist = " ("..radzonelevel2..")"
		end

		if hasgeiger then
			if radzonelevel > 0 then
				surface.SetFont("hl2_CinematicText")
				surface.SetTextColor(255, 0, 0, 255)
				surface.SetTextPos(64, ScrH() / 3)
				surface.DrawText(radzonelevel..resist.." рад/с")
			end
		end
	end

	hook.Add("PostDrawOpaqueRenderables", "ContainmentArea", function()
		if !cwRadSystem.show then return end
		if !LocalPlayer():IsSuperAdmin() then return end

		for k, v in pairs(cwRadSystem.localstored) do
			if v.pos then
				render.DrawWireframeSphere(v.pos, v.radius, 10, 10, Color(255,0,0), true)
			end
			if v.pos1 then
				if v.pos2 then
					render.DrawWireframeBox(Vector(0,0,0), Angle(0,0,0), v.pos1, v.pos2, Color(255,0,0), true)
				end
			end
		end
	end)

	netstream.Hook("cwRadSystemDataClear", function(data)
		cwRadSystem.localstored = {}
	end)
	netstream.Hook("cwRadSystemData", function(data)
		cwRadSystem.localstored[#cwRadSystem.localstored + 1] = {
			pos = data.pos,
			pos1 = data.pos1,
			pos2 = data.pos2,
			radius = data.radius,
			rad = data.rad
		}
	end)

	concommand.Add("cwradsys_show", function(ply)
		cwRadSystem.show = !cwRadSystem.show

		print(cwRadSystem.show)
	end)
end

local nonhumanoids = {
	"antlion",
	"antlion_guard",
	"antlion_guard",
	"antlion_guard",
	"headcrab",
	"headcrab_fast",
	"headcrab_poison",
	"barnacle",
	"bird_crow",
	"bird_pigeon",
	"bird_seagull",
	"zombie",
	"zombie_fast",
	"zombie_poison",
	"zombie_torso",
	"zombie_torso_fast",
}
local mechanics = {
	"ccamera",
	"cturret_ceiling",
	"cityscanner",
	"manhack",
	"hunter_chopper",
	"rollermine",
	"ccrawler",
	"clawscanner",
	"strider",
	"gunship",
	"cturret",
	"crab_synth",
	"dropship",
}
function cwRadSystem:PlayerIsBiotic(ply)
--[[
	local ent = pk_pills.getMappedEnt(ply)
	if IsValid(ent) then
		local class = ent:GetPillForm()
		for k, v in pairs(nonhumanoids) do
			if class == v then
				return true
			end
		end
	end

	return false
]]
end
function cwRadSystem:PlayerIsMechanic(ply)
--[[
	local ent = pk_pills.getMappedEnt(ply)
	if IsValid(ent) then
		local class = ent:GetPillForm()
		for k, v in pairs(mechanics) do
			if class == v then
				return true
			end
		end
	end

	return false
]]
end
function cwRadSystem:PlayerHasGeigerCounter(ply)
	if ply:GetFaction() == FACTION_OTA then
		return true
	elseif ply:GetFaction() == FACTION_MPF then
		return true
	end

	if self:PlayerIsMechanic(ply) then
		return true
	end

	if cw.player:HasFlags(ply, "]") then
		return true
	end

	if SERVER then
		if ply:GetInventory() then
			return ply:HasItemByID("geiger_counter")
		end
	else
		if cw.inventory:GetClient() then
			return cw.inventory:HasItemByID(cw.inventory:GetClient(), "geiger_counter")
		end
	end

	return false
end

function cwRadSystem:PlayerHasRadImmune(ply)
	if ply:GetCharacterData("isMutant", false) then
		return true
	end
	if self:PlayerIsBiotic(ply) then
		return true
	elseif self:PlayerIsMechanic(ply) then
		return true
	elseif ply:GetFaction() == FACTION_VORT then
		return true
	end

	return false
end
