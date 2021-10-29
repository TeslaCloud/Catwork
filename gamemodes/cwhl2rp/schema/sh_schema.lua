--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

util.Include("cl_schema.lua")
util.Include("cl_hooks.lua")
util.Include("cl_theme.lua")
util.Include("sv_schema.lua")
util.Include("sv_hooks.lua")

Schema.customPermits = Schema.customPermits or {}

Schema.City = "City-24"
Schema.City_cp = "C24"
Schema.CitizenFactions = {
	"#Faction_Citizen",
	"#Faction_CWU",
	"#Faction_Rebel",
	"#Faction_Loyalist",
	"#Faction_Vort",
	"#Faction_Refugee",
	"#Faction_Admin"
}

Schema.CitizenStates = {
	Unverified = Color(150, 150, 150),
	Citizen = Color(70, 140, 70),
	AntiCitizen = Color(140, 70, 70),
	NoData = Color(70, 70, 140),
	Unknown = Color(170, 170, 0),
	Deceased = Color(40, 40, 40)
}

Schema.LoyalistTiers = {} -- has to go on refresh

for k, v in ipairs(_file.Find("models/humans/group17/*.mdl", "GAME")) do
	cw.animation:AddMaleHumanModel("models/humans/group17/"..v)
end

cw.animation:AddCivilProtectionModel("models/eliteghostcp.mdl")
cw.animation:AddCivilProtectionModel("models/eliteshockcp.mdl")
cw.animation:AddCivilProtectionModel("models/leet_police2.mdl")
cw.animation:AddCivilProtectionModel("models/sect_police2.mdl")
cw.animation:AddCivilProtectionModel("models/policetrench.mdl")
cw.animation:AddCivilProtectionModel("models/metropolice/c08.mdl")
cw.animation:AddFemaleCivilProtectionModel("models/metropolice/c08_female.mdl")
cw.animation:AddFemaleCivilProtectionModel("models/metropolice/c08_female_2.mdl")

for i = 1, 24 do
	cw.animation:AddCivilProtectionModel("models/half_life2/jnstudio/cp_c08_"..i..".mdl")
end

for i = 1, 7 do
	cw.animation:AddFemaleCivilProtectionModel("models/half_life2/jnstudio/cp_female_c08_"..i..".mdl")
end

cw.animation:AddCombineOverwatchModel("models/city8_ow_elite.mdl")
cw.animation:AddCombineOverwatchModel("models/city8_overwatch.mdl")
cw.animation:AddCombineOverwatchModel("models/city8_overwatch_elite.mdl")
cw.animation:AddCombineOverwatchModel("models/city8ow.mdl")

cw.animation:AddVortigauntModel("models/vortigaunt_ozaxi.mdl")

cw.option:SetKey("default_date", {month = 1, year = 2016, day = 1})
cw.option:SetKey("default_time", {minute = 0, hour = 0, day = 1})
cw.option:SetKey("format_singular_cash", "%a")
cw.option:SetKey("model_shipment", "models/items/item_item_crate.mdl")
cw.option:SetKey("intro_image", "halfliferp/logo4")
cw.option:SetKey("schema_logo", "halfliferp/logo4")
cw.option:SetKey("format_cash", "%a %n")
cw.option:SetKey("menu_music", "")
cw.option:SetKey("name_cash", "#HL2RP_CashName")
cw.option:SetKey("model_cash", "models/props_lab/box01a.mdl")
cw.option:SetKey("gradient", "halfliferp/bg_gradient")

config.ShareKey("intro_text_small")
config.ShareKey("intro_text_big")
config.ShareKey("business_cost")
config.ShareKey("permits")
config.ShareKey("sxbase_force_fov")

cw.quiz:SetEnabled(true)
cw.quiz:AddQuestion("Что необходимо для RolePlay", 3,
					"Администрация",
					"Предметы",
					"Чат или другой способ коммуникации",--
					"Команды '/me', '/it', '/roll' и др.",
					"Персонаж в какой-либо фракции")

cw.quiz:AddQuestion("Выберите корректное описание персонажа.", 2,
					"Мужик высотой 2.5 метра мускулистого телосложения.",
					"Мужчина|Темные волосы и карие глаза, имеется бородка|Одет в чистую форму гражданина 'City 17'",--
					"Гражданин, долгое время трудящийся на благо Альянса. По натуре добрый и отзывчивый.",
					"Мужчина / 23-25 лет / Рост 180-185 см / Вес 80 кг / Арбалет [СПРЯТАН]")

cw.quiz:AddQuestion("Вы отыгрываете действие против окружения. Как определить, успешно ли действие?", 2,
					"Кинуть /roll 2 раза, если последний ролл больше - успех.",
					"Кинуть /roll, если значение больше или равно 50 - успех.",--
					"Действия против окружения отыгрываются без /roll.")

cw.quiz:AddQuestion("Выберите правильное действие при РП бое.", 3,
					"/me ударил",
					"/me пинком в солнечное сплетение вывел из строя противника.",
					"/me попытался ударить гражданина кулаком в живот.");--

cw.flag:Add("v", "Light Blackmarket", "Access to light blackmarket goods.")
cw.flag:Add("V", "Heavy Blackmarket", "Access to heavy blackmarket goods.")
cw.flag:Add("m", "Resistance Manager", "Access to the resistance manager's goods.")
cw.flag:Add("d", "Perma Death", "Disables permanent kill on character's death.")

function Schema:DefineLoyalistTier(name, description, color, min, max)
	return table.insert(self.LoyalistTiers, {
		name = name,
		description = description,
		color = color,
		min = min,
		max = max
	})
end

function Schema:DetermineLoyalistTier(num)
	local tier = nil -- we do this to let it loop through everything and see if we've hit the limit.

	for k, v in ipairs(self.LoyalistTiers) do
		if (num >= v.min and ((v.max == -1 and true) or num <= v.max)) then
			tier = v
		end
	end

	return tier or self.LoyalistTiers[1] or {name = "ERROR", description = "ERROR", color = Color(255, 0, 255), min = -1, max = -1}
end

function Schema:PlayerIsLoyalistTier(player, tier)
	local points = player:GetCharacterData("LoyaltyPoints", 0)
	local tierObj = self:DetermineLoyalistTier(points)

	if (tierObj) then
		return tierObj.name:utf8lower():find(tier:utf8lower())
	end

	return false
end

Schema:DefineLoyalistTier("#Loyalist_Grey", "A citizen with no real rights or power", Color(150, 150, 150), 0, 10)
Schema:DefineLoyalistTier("#Loyalist_White", "An ordinary citizen.", Color(255, 255, 255), 11, 30)
Schema:DefineLoyalistTier("#Loyalist_Green", "A citizen, distinguished for their service to the Universal Union.", Color(120, 210, 120), 31, 60)
Schema:DefineLoyalistTier("#Loyalist_Blue", "Lower tier loyalist that has pledged to serve to the Combine.", Color(100, 100, 210), 61, 100)
Schema:DefineLoyalistTier("#Loyalist_Orange", "Highly reputable higher tier loyalist.", Color(210, 180, 50), 101, 149)
Schema:DefineLoyalistTier("#Loyalist_Red", "Ultimate tier loyalist with more rights than some CP recruits.", Color(210, 100, 100), 150, -1)

function Schema:CanUseCP(player)
	return true
end

-- A function to add a custom permit.
function Schema:AddCustomPermit(name, flag, model)
	local formattedName = string.gsub(name, "[%s%p]", "")
	local lowerName = string.lower(name)

	self.customPermits[string.lower(formattedName)] = {
		model = model,
		name = name,
		flag = flag,
		key = cw.core:SetCamelCase(formattedName, true)
	}
end

-- A function to check if a string is a Combine rank.
function Schema:IsStringCombineRank(text, rank)
	if (type(rank) == "table") then
		for k, v in ipairs(rank) do
			if (self:IsStringCombineRank(text, v)) then
				return true
			end
		end
	elseif (rank == "EpU") then
		if (string.find(text, "%pSeC%p") or string.find(text, "%pDvL%p")
		or string.find(text, "%pEpU%p") or string.find(text, "%pCmD%p")) then
			return true
		end
	else
		return string.find(text, "%p"..rank.."%p")
	end
end

-- A function to check if a player is a Combine rank.
function Schema:IsPlayerCombineRank(player, rank, realRank)
	local name = player:Name()
	local faction = player:GetFaction()

	if (self:IsCombineFaction(faction)) then
		if (type(rank) == "table") then
			for k, v in ipairs(rank) do
				if (self:IsPlayerCombineRank(player, v, realRank)) then
					return true
				end
			end
		elseif (rank == "EpU" and !realRank) then
			if (string.find(name, "%pSeC%p") or string.find(name, "%pDvL%p")
			or string.find(name, "%pEpU%p") or string.find(name, "%pCmD%p")) then
				return true
			end
		else
			return string.find(name, "%p"..rank.."%p")
		end
	end
end

-- A function to get a player's Combine rank.
function Schema:GetPlayerCombineRank(player)
	local faction = player:GetFaction()

	if (faction == FACTION_OTA) then
		if (self:IsPlayerCombineRank(player, "OWS")) then
			return 0
		elseif (self:IsPlayerCombineRank(player, "OWC")) then
			return 1
		elseif (self:IsPlayerCombineRank(player, "EOW")) then
			return 2
		else
			return 3
		end
	elseif (self:IsPlayerCombineRank(player, "RCT")) then
		return 0
	elseif (self:IsPlayerCombineRank(player, "04")) then
		return 1
	elseif (self:IsPlayerCombineRank(player, "03")) then
		return 2
	elseif (self:IsPlayerCombineRank(player, "02")) then
		return 3
	elseif (self:IsPlayerCombineRank(player, "01")) then
		return 4
	elseif (self:IsPlayerCombineRank(player, "GHOST")) then
		return 6
	elseif (self:IsPlayerCombineRank(player, "OfC")) then
		return 7
	elseif (self:IsPlayerCombineRank(player, "EpU", true)) then
		return 8
	elseif (self:IsPlayerCombineRank(player, "DvL")) then
		return 9
	elseif (self:IsPlayerCombineRank(player, "CmD")) then
		return 10
	elseif (self:IsPlayerCombineRank(player, "SCN")) then
		if (!self:IsPlayerCombineRank(player, "SYNTH")) then
			return 11
		else
			return 12
		end
	else
		return 5
	end
end

-- A function to get if a faction is Combine.
function Schema:IsCombineFaction(faction)
	return (faction == FACTION_MPF or faction == FACTION_OTA)
end

function Schema:GetLP(player)
	return player:GetNetVar("LoyaltyPoints", 0)
end

function Schema:GetCP(player)
	return player:GetNetVar("CriminalPoints", 0)
end

function Schema:GetCitizenStatus(player)
	return player:GetNetVar("CitizenStatus", "Unknown")
end

function Schema:GetResidence(player)
	return player:GetNetVar("Residence", "Unknown")
end

function Schema:GetJailed(player)
	return player:GetNetVar("Jailed", false)
end

function Schema:GetJob(player)
	return player:GetNetVar("Job", "None")
end

function Schema:GetWorkPoints(player)
	return player:GetNetVar("WorkPoints", 0)
end

function Schema:GetCitizenStatusColor(player)
	return self.CitizenStates[self:GetCitizenStatus(player)] or Color(255, 255, 255)
end

do
	local playerMeta = FindMetaTable("Player")

	function playerMeta:IsCombine()
		if (SERVER) then
			if (self:GetCharacter()) then
				local faction = self:GetFaction()

				if (Schema:IsCombineFaction(faction) or faction == FACTION_ADMIN) then
					return true
				end
			end
		else
			local faction = self:GetFaction()

			if (Schema:IsCombineFaction(faction) or faction == FACTION_ADMIN) then
				return true
			end
		end
	end

	function playerMeta:IsCitizen()
		return table.HasValue(Schema.CitizenFactions, self:GetFaction())
	end
end
