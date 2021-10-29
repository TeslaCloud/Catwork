--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

Schema.scannerSounds = {
	"npc/scanner/cbot_servochatter.wav",
	"npc/scanner/cbot_servoscared.wav",
	"npc/scanner/scanner_blip1.wav",
	"npc/scanner/scanner_scan1.wav",
	"npc/scanner/scanner_scan2.wav",
	"npc/scanner/scanner_scan4.wav",
	"npc/scanner/scanner_scan5.wav",
	"npc/scanner/combat_scan1.wav",
	"npc/scanner/combat_scan2.wav",
	"npc/scanner/combat_scan3.wav",
	"npc/scanner/combat_scan4.wav",
	"npc/scanner/combat_scan5.wav"
}
Schema.scanners = Schema.scanners or {}
Schema.cwuProps = {
	"models/props_c17/furniturewashingmachine001a.mdl",
	"models/props_interiors/furniture_vanity01a.mdl",
	"models/props_interiors/furniture_couch02a.mdl",
	"models/props_interiors/furniture_shelf01a.mdl",
	"models/props_interiors/furniture_chair01a.mdl",
	"models/props_interiors/furniture_desk01a.mdl",
	"models/props_interiors/furniture_lamp01a.mdl",
	"models/props_c17/furniturecupboard001a.mdl",
	"models/props_c17/furnituredresser001a.mdl",
	"props/props_c17/furniturefridge001a.mdl",
	"models/props_c17/furniturestove001a.mdl",
	"models/props_interiors/radiator01a.mdl",
	"props/props_c17/furniturecouch001a.mdl",
	"models/props_combine/breenclock.mdl",
	"props/props_combine/breenchair.mdl",
	"models/props_c17/shelfunit01a.mdl",
	"props/props_combine/breendesk.mdl",
	"models/props_lab/monitor01b.mdl",
	"models/props_lab/monitor01a.mdl",
	"models/props_lab/monitor02.mdl",
	"models/props_c17/frame002a.mdl",
	"models/props_c17/bench01a.mdl"
}

cw.core:AddFile("resource/fonts/mailartrubberstamp.ttf")
cw.core:AddFile("models/eliteghostcp.mdl")
cw.core:AddFile("models/eliteshockcp.mdl")
cw.core:AddFile("models/policetrench.mdl")
cw.core:AddFile("models/leet_police2.mdl")
cw.core:AddFile("models/sect_police2.mdl")
cw.core:AddFile("halfliferp/logo4.png")

config.Add("server_whitelist_identity", "")
config.Add("combine_lock_overrides", false)
config.Add("intro_text_small", "The city of wonders.", true)
config.Add("intro_text_big", "CITY-24, 2018.", true)
config.Add("knockout_time", 60)
config.Add("business_cost", 160, true)
config.Add("cwu_props", true)
config.Add("permits", true, true)
config.Add("voice_cooldown", 15)
config.Add("sxbase_force_fov", 0)
config.Add("enable_permakill", false)

config.Get("enable_gravgun_punt"):Set(false)
config.Get("default_inv_weight"):Set(6)
config.Get("enable_crosshair"):Set(true)
config.Get("disable_sprays"):Set(false)
config.Get("prop_cost"):Set(false)
config.Get("door_cost"):Set(0)

-- A function to add a human hint.
function cw.hint:AddHumanHint(name, text, combine)
	cw.hint:Add(name, text, function(player)
		if (IsValid(player)) then
			return !player:IsCombine()
		end
	end)
end

cw.hint:AddHumanHint("Life", "Вам следует ценить жизнь своего персонажа. Не совершайте необдуманных действий.", false)
cw.hint:AddHumanHint("Sleep", "Не забывайте, что Ваш персонаж устает. Здоровый сон необходим всем.", false)
cw.hint:AddHumanHint("Friends", "Заведите друзей. Отыгрывать в компании веселее.", false)

cw.hint:AddHumanHint("Curfew", "Бродите по городу в гордом одиночестве? Познакомьтесь с кем-нибудь.")
cw.hint:AddHumanHint("Prison", "Не стоит нарушать закон. Оно того не стоит, поверьте.")
cw.hint:AddHumanHint("Rebels", "Не связывайтесь с Сопротивлением. Альянс жестко расправляется с нарушителями.")
cw.hint:AddHumanHint("Talking", "Не материтесь. Это некультурно.")
cw.hint:AddHumanHint("Rations", "Рационы - Ваше всё. В них есть все, что нужно для жизни.")
cw.hint:AddHumanHint("Combine", "Не недооценивайте Альянс. Они захватили Землю за 7 часов.")
cw.hint:AddHumanHint("Jumping", "Прыжки и бег не свойственны поведению цивилизованного человека, помните об этом.")
cw.hint:AddHumanHint("Punching", "Не начинайте драку без веской причины. Это наказуемо.")
cw.hint:AddHumanHint("Compliance", "Подчиняйтесь Альянсу. Вы будете рады тому, что сделали.")
cw.hint:AddHumanHint("Combine Raids", "Не мешайте сотрудникам ГО выполнять их работу.")
cw.hint:AddHumanHint("Request Device", "Необходимо присутсвие ГО? Приобретите устройство запроса.")
cw.hint:AddHumanHint("Civil Protection", "Гражданская Оборона защищает гражданское общество, не Вас.")

cw.hint:Add("Admins", "Уважайте администрацию, других игроков, себя.")
cw.hint:Add("Action", "Видите, что ничего не происходит и становится скучно? Устройте какую-нибудь авантюру.")
cw.hint:Add("Grammar", "Пишите грамотно, будто вы на уроке русского языка.")
cw.hint:Add("Running", "Не забывайте, что бегать нецивилизованно. Если что, ГО напомнит.")
cw.hint:Add("Healing", "С помощью медикаментов можно лечить других игроков.")
cw.hint:Add("F3 Hotkey", "Нажмите F3, глядя на персонажа, чтобы связать его.")
cw.hint:Add("F4 Hotkey", "Нажмите F3, глядя на связанного персонажа, чтобы обыскать его.")
cw.hint:Add("Attributes", "Нашли баг, ошибку или недоработку? Сообщите о ней администрации или в грппу STEAM.")
cw.hint:Add("Firefights", "Не забывайте соблюдать правило 'Shoot-2-miss', стреляйте мимо, это сделает перестрелки интереснее.")
cw.hint:Add("Metagaming", "Использование неигровой информации при отыгрыше наказуемо.")
cw.hint:Add("Passive RP", "Устали от множества событий? Попробуйте пассивный RolePlay.")
cw.hint:Add("Development", "Развивайте Вашего персонажа. Его история намного ценнее, чем игромеханические ценности.")
cw.hint:Add("Powergaming", "Отыгрывайте не в свою пользу. Это сделает отыгрыш увлекательным как для Вас, так и других.")
cw.hint:Add("LOOC Spam", "Конфликтная ситуация? Прекратите писать в LOOC и отыгрывайте!")
cw.hint:Add("Uncommon Situation", "Нестандартная ситуация? Не задавайте вопросов в ООС и отыгрывайте!")
cw.hint:Add("PainRP", "В полной мере отыгрывайте свои ранения. Раны долго заживают.")
cw.hint:Add("FearRP", "Страх - защитная реакция организма. Отыгрывайте его.")
cw.hint:Add("Original", "Оригинальный отыгрыш поощряется.")

netstream.Hook("EditObjectives", function(player, data)
	if (player.editObjectivesAuthorised and type(data) == "string") then
		if (Schema.combineObjectives != data) then
			Schema:AddCombineDisplayLine("Загрузка списка актуальных задач...", Color(255, 100, 255, 255))
			Schema.combineObjectives = string.sub(data, 0, 500)

			cw.core:SaveSchemaData("objectives", {
				text = Schema.combineObjectives
			})

			timer.Simple(0.1, function()
				local players = {}
			
				for k, v in ipairs( _player.GetAll() ) do
					if (v:IsCombine() and v != exclude and !v:GetSharedVar("IsBiosignalGone")) then
						players[#players + 1] = v
					end
				end
				
				netstream.Start(players, "RecalculateHUDObjectives", {cwCTO.socioStatus, Schema.combineObjectives})
			end)
		end

		player.editObjectivesAuthorised = nil
	end
end)

netstream.Hook("ObjectPhysDesc", function(player, data)
	if (type(data) == "table" and type(data[1]) == "string") then
		if (player.objectPhysDesc == data[2]) then
			local physDesc = data[1]

			if (string.len(physDesc) > 80) then
				physDesc = string.sub(physDesc, 1, 80).."..."
			end

			data[2]:SetNWString("physDesc", physDesc)
		end
	end
end)

netstream.Hook("EditData", function(player, data)
	if (player.editDataAuthorised == data[1] and type(data[2]) == "string") then
		data[1]:SetCharacterData("combinedata", string.sub(data[2], 0, 500))

		player.editDataAuthorised = nil
	end
end)

function Schema:SendIconData(player, bOneWay)
	-- First send custom icon data to everybody already on the server.
	local iconData = player:GetData("CustomIcon")

	if (istable(iconData)) then
		netstream.Start(nil, "PlayerSetCustomIcon", player, iconData, bOneWay)
	end

	if (!bOneWay) then
		-- Then send everyone's icons to our newly connected player.
		for k, v in ipairs(_player.GetAll()) do
			if (v == player) then continue end

			iconData = v:GetData("CustomIcon")

			if (istable(iconData)) then
				netstream.Start(player, "PlayerSetCustomIcon", v, iconData)
			end
		end
	end
end

function Schema:SetLP(player, amt)
	amt = math.Round(tonumber(amt))

	player:SetCharacterData("LoyaltyPoints", amt)
	player:SetNetVar("LoyaltyPoints", amt)
end

function Schema:SetCP(player, amt)
	amt = math.Round(tonumber(amt))

	player:SetCharacterData("CriminalPoints", amt)
	player:SetNetVar("CriminalPoints", amt)
end

function Schema:AddLP(player, amt)
	self:SetLP(player, self:GetLP(player) + tonumber(amt))
end

function Schema:AddCP(player, amt)
	self:SetCP(player, self:GetCP(player) + tonumber(amt))
end

function Schema:SubstractLP(player, amt)
	self:AddLP(player, -amt)
end

function Schema:SubstractCP(player, amt)
	self:AddCP(player, -amt)
end

function Schema:SetCitizenStatus(player, status)
	status = (self.CitizenStates[status] and status) or "unknown"

	player:SetCharacterData("CitizenStatus", status)
	player:SetNetVar("CitizenStatus", status)
end

function Schema:SetResidence(player, value)
	player:SetCharacterData("Residence", value)
	player:SetNetVar("Residence", value)
end

function Schema:SetJailed(player, value)
	value = tobool(value)

	player:SetCharacterData("Jailed", value)
	player:SetNetVar("Jailed", value)
end

function Schema:SetJob(player, value)
	player:SetCharacterData("Job", value)
	player:SetNetVar("Job", amt)
end

function Schema:SetWorkPoints(player, value)
	value = math.Round(tonumber(value))

	player:SetCharacterData("WorkPoints", value)
	player:SetNetVar("WorkPoints", value)
end

function Schema:AddWorkPoints(player, amt)
	self:SetWorkPoints(player, self:GetWorkPoints(player) + tonumber(amt))
end

-- A function to calculate a player's scanner think.
function Schema:CalculateScannerThink(player, curTime)
	if (!self.scanners[player]) then return end

	local scanner = self.scanners[player][1]
	local marker = self.scanners[player][2]

	if (IsValid(scanner) and IsValid(marker)) then
		scanner:SetMaxHealth(player:GetMaxHealth())

		player:SetMoveType(MOVETYPE_OBSERVER)
		player:SetHealth(math.max(scanner:Health(), 0))

		if (!player.nextScannerSound or curTime >= player.nextScannerSound) then
			player.nextScannerSound = curTime + math.random(8, 48)

			scanner:EmitSound(self.scannerSounds[math.random(1, #self.scannerSounds)])
		end
	end
end

-- A function to reset a player's scanner.
function Schema:ResetPlayerScanner(player, noMessage)
	if (self.scanners[player]) then
		local scanner = self.scanners[player][1]
		local marker = self.scanners[player][2]

		if (IsValid(scanner)) then
			scanner:Remove()
		end

		if (IsValid(marker)) then
			marker:Remove()
		end

		self.scanners[player] = nil

		if (!noMessage) then
			player:SetMoveType(MOVETYPE_WALK)
			player:UnSpectate()
			player:KillSilent()
		end
	end
end

-- A function to make a player a scanner.
function Schema:MakePlayerScanner(player, noMessage, lightSpawn)
	self:ResetPlayerScanner(player, noMessage)

	local scannerClass = "npc_cscanner"

	if (self:IsPlayerCombineRank(player, "SYNTH")) then
		scannerClass = "npc_clawscanner"
	end

	local position = player:GetShootPos()
	local uniqueID = player:UniqueID()
	local scanner = ents.Create(scannerClass)
	local marker = ents.Create("path_corner")

	cw.entity:SetPlayer(scanner, player)

	scanner:SetPos(position + Vector(0, 0, 16))
	scanner:SetAngles(player:GetAimVector():Angle())
	scanner:SetKeyValue("targetname", "scanner_"..uniqueID)
	scanner:SetKeyValue("spawnflags", 8592)
	scanner:SetKeyValue("renderfx", 0)
	scanner:Spawn(); scanner:Activate()

	marker:SetKeyValue("targetname", "marker_"..uniqueID)
	marker:SetPos(position)
	marker:Spawn(); marker:Activate()

	if (!lightSpawn) then
		player:Flashlight(false)
		player:RunCommand("-duck")

		if (scannerClass == "npc_clawscanner") then
			player:SetHealth(200)
		end
	end

	player:SetArmor(0)
	player:Spectate(OBS_MODE_CHASE)
	player:StripWeapons()
	player:SetNetVar("scanner", scanner:EntIndex())
	player:SetMoveType(MOVETYPE_OBSERVER)
	player:SpectateEntity(scanner)

	scanner:SetMaxHealth(player:GetMaxHealth())
	scanner:SetHealth(player:Health())
	scanner:Fire("SetDistanceOverride", 64, 0)
	scanner:Fire("SetFollowTarget", "marker_"..uniqueID, 0)

	self.scanners[player] = {scanner, marker}

	timer.Create("scanner_sound_"..uniqueID, 0.01, 1, function()
		if (IsValid(scanner)) then
			scanner.flyLoop = CreateSound(scanner, "npc/scanner/cbot_fly_loop.wav")
			scanner.flyLoop:Play()
		end
	end)

	scanner:CallOnRemove("Scanner Sound", function(scanner)
		if (scanner.flyLoop) then
			scanner.flyLoop:Stop()
		end
	end)
end

-- A function to add a Combine display line.
function Schema:AddCombineDisplayLine(text, color, player, exclude)
	if (player) then
		netstream.Start(player, "CombineDisplayLine", {text, color})
	else
		local players = {}

		for k, v in ipairs(_player.GetAll()) do
			if (v:IsCombine() and v != exclude) then
				players[#players + 1] = v
			end
		end

		netstream.Start(players, "CombineDisplayLine", {text, color})
	end
end

-- A function to load the objectives.
function Schema:LoadObjectives()
	local combineObjectives = cw.core:RestoreSchemaData("objectives")

	if (combineObjectives and combineObjectives.text) then
		self.combineObjectives = combineObjectives.text
	else
		self.combineObjectives = ""
	end
end

-- A function to load the NPCs.
function Schema:LoadNPCs()
	local npcs = cw.core:RestoreSchemaData("plugins/npcs/"..game.GetMap())

	for k, v in pairs(npcs) do
		local entity = ents.Create(v.class)

		if (IsValid(entity)) then
			entity:SetKeyValue("spawnflags", v.spawnFlags or 0)
			entity:SetKeyValue("additionalequipment", v.equipment or "")
			entity:SetAngles(v.angles)
			entity:SetModel(v.model)
			entity:SetPos(v.position)
			entity:Spawn()

			if (IsValid(entity)) then
				entity:Activate()

				entity:SetNWString("cw_Name", v.name)
				entity:SetNWString("cw_Title", v.title)
			end
		end
	end
end

-- A function to save the NPCs.
function Schema:SaveNPCs()
	local npcs = {}

	for k, v in pairs(ents.FindByClass("npc_*")) do
		local name = v:GetNWString("cw_Name")
		local title = v:GetNWString("cw_Title")

		if (name != "" and title != "") then
			local keyValues = table.LowerKeyNames(v:GetKeyValues())
			
			npcs[#npcs + 1] = {
				spawnFlags = keyValues["spawnflags"],
				equipment = keyValues["additionequipment"],
				position = v:GetPos(),
				angles = v:GetAngles(),
				model = v:GetModel(),
				title = title,
				class = v:GetClass(),
				name = name
			}
		end
	end

	cw.core:SaveSchemaData("plugins/npcs/"..game.GetMap(), npcs)
end
-- A function to load the radios.
function Schema:LoadRadios()
	local radios = cw.core:RestoreSchemaData("plugins/radios/"..game.GetMap())

	for k, v in pairs(radios) do
		local entity = ents.Create("cw_radio")

		cw.player:GivePropertyOffline(v.key, v.uniqueID, entity)

		entity:SetAngles(v.angles)
		entity:SetPos(v.position)
		entity:Spawn()

		if (IsValid(entity)) then
			entity:SetFrequency(v.frequency)
			entity:SetOff(v.off)
		end

		if (!v.moveable) then
			local physicsObject = entity:GetPhysicsObject()

			if (IsValid(physicsObject)) then
				physicsObject:EnableMotion(false)
			end
		end
	end
end

-- A function to load the ration dispensers.
function Schema:LoadRationDispensers()
	local dispensers = cw.core:RestoreSchemaData("plugins/dispensers/"..game.GetMap())

	for k, v in pairs(dispensers) do
		local entity = ents.Create("cw_rationdispenser")

		entity:SetPos(v.position)
		entity:Spawn()

		if (IsValid(entity)) then
			entity:SetAngles(v.angles)

			if (!v.locked) then
				entity:Unlock()
			else
				entity:Lock()
			end
		end
	end
end

-- A function to save the ration dispensers.
function Schema:SaveRationDispensers()
	local dispensers = {}

	for k, v in pairs(ents.FindByClass("cw_rationdispenser")) do
		dispensers[#dispensers + 1] = {
			locked = v:IsLocked(),
			angles = v:GetAngles(),
			position = v:GetPos()
		}
	end

	cw.core:SaveSchemaData("plugins/dispensers/"..game.GetMap(), dispensers)
end

-- A function to load the ration machines.
function Schema:LoadVendingMachines()
	local machines = cw.core:RestoreSchemaData("plugins/machines/"..game.GetMap())

	for k, v in pairs(machines) do
		local entity = ents.Create("cw_vendingmachine")

		entity:SetPos(v.position)
		entity:Spawn()

		if (IsValid(entity)) then
			entity:SetAngles(v.angles)
			entity:SetStock(v.stock, v.defaultStock)
		end
	end
end

-- A function to save the ration machines.
function Schema:SaveVendingMachines()
	local machines = {}

	for k, v in pairs(ents.FindByClass("cw_vendingmachine")) do
		machines[#machines + 1] = {
			stock = v:GetStock(),
			angles = v:GetAngles(),
			position = v:GetPos(),
			defaultStock = v:GetDefaultStock()
		}
	end

	cw.core:SaveSchemaData("plugins/machines/"..game.GetMap(), machines)
end

-- A function to save the radios.
function Schema:SaveRadios()
	local radios = {}

	for k, v in pairs(ents.FindByClass("cw_radio")) do
		local physicsObject = v:GetPhysicsObject()
		local moveable

		if (IsValid(physicsObject)) then
			moveable = physicsObject:IsMoveable()
		end

		radios[#radios + 1] = {
			off = v:IsOff(),
			key = cw.entity:QueryProperty(v, "key"),
			angles = v:GetAngles(),
			moveable = moveable,
			uniqueID = cw.entity:QueryProperty(v, "uniqueID"),
			position = v:GetPos(),
			frequency = v:GetFrequency()
		}
	end

	cw.core:SaveSchemaData("plugins/radios/"..game.GetMap(), radios)
end

-- A function to say a message as a request.
function Schema:SayRequest(player, text)
	local isCitizen = (player:GetFaction() == FACTION_CITIZEN)
	local listeners = { request = {}, eavesdrop = {} }

	for k, v in ipairs(_player.GetAll()) do
		if (v:HasInitialized()) then
			if (v:GetFaction() == FACTION_CITIZEN and isCitizen and player != v) then
				if (v:GetShootPos():Distance(player:GetShootPos()) <= config.Get("talk_radius"):Get()) then
					listeners.eavesdrop[v] = v
				end
			else
				local isCityAdmin = (v:GetFaction() == FACTION_ADMIN or v:GetFaction() == FACTION_CWU)
				local isCombine = v:IsCombine()

				if (v:HasItemByID("request_device") or isCombine or isCityAdmin) then
					listeners.request[v] = v
				end
			end
		end
	end

	local cid

	local ciD = player:GetCharacterData("citizenid", 0)
	if ciD == 0 then
		cid = "N/A"
	else
		cid = ciD
	end

	self:AddCombineDisplayLine("!ЗПРС: Гражданский: "..player:Name()..", #"..ciD..": "..text, Color(218, 165, 32, 255))

	local info = chatbox.AddText(listeners.request, "\""..text.."\"", {suffix = " запрашивает: ", sender = player, isPlayerMessage = true, filter = "ic", radius = 0, textColor = Color(175, 125, 100, 255), data = {request = true}})

	if (info and IsValid(info.sender)) then
		chatbox.AddText(listeners.eavesdrop, "\""..info.text.."\"", {suffix = " запрашивает: ", sender = info.sender, isPlayerMessage = true, filter = "ic", radius = 0, textColor = Color(255, 255, 150, 255), data = {request = true}})
		chatbox.AddText(player, info.text.."\"", {suffix = " запрашивает: ", sender = info.sender, isPlayerMessage = true, filter = "ic", radius = 0, textColor = Color(255, 255, 150, 255), data = {request = true}})
	end
end

-- A function to get a player's location.
function Schema:PlayerGetLocation(player)
	local areaNames = plugin.FindByID("Area Names")
	local closest

	if (areaNames) then
		for k, v in pairs(areaNames.areaNames) do
			if (cw.entity:IsInBox(player, v.minimum, v.maximum)) then
				if (string.sub(string.lower(v.name), 1, 4) == "the ") then
					return string.sub(v.name, 5)
				else
					return v.name
				end
			else
				local distance = player:GetShootPos():Distance(v.minimum)

				if (!closest or distance < closest[1]) then
					closest = {distance, v.name}
				end
			end
		end

		if (!completed) then
			if (closest) then
				if (string.sub(string.lower(closest[2]), 1, 4) == "the ") then
					return string.sub(closest[2], 5)
				else
					return closest[2]
				end
			end
		end
	end

	return "неизвестная локация"
end

-- A function to say a message as a broadcast.
function Schema:SayBroadcast(player, text)
	chatbox.AddText(nil, "\""..text.."\"", {suffix = " сообщает: ", sender = player, isPlayerMessage = true, filter = "ic", radius = 0, textColor = Color(150, 125, 175, 255)})
end

-- A function to say a message as a dispatch.
function Schema:SayDispatch(player, text)
	chatbox.AddText(nil, "\""..text.."\"", {sender = player, suffix = " сообщает: ", playerName = "Система оповещения", forceName = true, isPlayerMessage = true, filter = "ic", radius = 0, textColor = Color(150, 100, 100, 255), data = {dispatch = true}})
end

-- A function to check if a player is Combine.
function Schema:PlayerIsCombine(player)
	if (IsValid(player)) then
		return player:IsCombine()
	end
end

-- A function to check if a player is Combine.
function Schema:PlayerIsCWU(player)
	if (IsValid(player) and player:GetCharacter()) then
		local faction = player:GetFaction()

		return faction == FACTION_CWU
	end
end

-- A function to apply a Combine lock.
function Schema:ApplyCombineLock(entity, position, angles)
	local combineLock = ents.Create("cw_combinelock")

	combineLock:SetParent(entity)
	combineLock:SetDoor(entity)

	if (position) then
		if (type(position) == "table") then
			combineLock:SetLocalPos(Vector(-1.0313, 43.7188, -1.2258))
			combineLock:SetPos(combineLock:GetPos() + (position.HitNormal * 4))
		else
			combineLock:SetPos(position)
		end
	end

	if (angles) then
		combineLock:SetAngles(angles)
	end

	combineLock:Spawn()

	if (IsValid(combineLock)) then
		return combineLock
	end
end

-- A function to make a player wear clothes.
function Schema:PlayerWearClothes(player, itemTable, noMessage)
	local clothes = player:GetCharacterData("clothes")

	if (itemTable) then
		local model = cw.class:GetAppropriateModel(player:Team(), player, true)

		if (!model) then
			itemTable:OnChangeClothes(player, true)

			player:SetCharacterData("clothes", itemTable.index)
			player:SetNetVar("clothes", itemTable.index)
		end
	else
		itemTable = item.FindByID(clothes)

		if (itemTable) then
			itemTable:OnChangeClothes(player, false)

			player:SetCharacterData("clothes", nil)
			player:SetNetVar("clothes", 0)
		end
	end
end

-- A function to get a player's heal amount.
function Schema:GetHealAmount(player, scale)
	local medical = cw.attributes:Fraction(player, ATB_MEDICAL, 35)
	local healAmount = (15 + medical) * (scale or 1)

	return healAmount
end

-- A function to get a player's dexterity time.
function Schema:GetDexterityTime(player)
	return 7 - cw.attributes:Fraction(player, ATB_AGILITY, 5, 5)
end

-- A function to bust down a door.
function Schema:BustDownDoor(player, door, force)
	door.bustedDown = true

	door:SetNotSolid(true)
	door:DrawShadow(false)
	door:SetNoDraw(true)
	door:EmitSound("physics/wood/wood_box_impact_hard3.wav")
	door:Fire("unlock", "", 0)

	if (IsValid(door.combineLock)) then
		door.combineLock:Explode()
		door.combineLock:Remove()
	end

	if (IsValid(door.breach)) then
		door.breach:BreachEntity()
	end

	local fakeDoor = ents.Create("prop_physics")

	fakeDoor:SetCollisionGroup(COLLISION_GROUP_WORLD)
	fakeDoor:SetAngles(door:GetAngles())
	fakeDoor:SetModel(door:GetModel())
	fakeDoor:SetSkin(door:GetSkin())
	fakeDoor:SetPos(door:GetPos())
	fakeDoor:Spawn()

	local physicsObject = fakeDoor:GetPhysicsObject()

	if (IsValid(physicsObject)) then
		if (!force) then
			if (IsValid(player)) then
				physicsObject:ApplyForceCenter((door:GetPos() - player:GetPos()):GetNormal() * 10000)
			end
		else
			physicsObject:ApplyForceCenter(force)
		end
	end

	cw.entity:Decay(fakeDoor, 300)

	timer.Create("reset_door_"..door:EntIndex(), 300, 1, function()
		if (IsValid(door)) then
			door.bustedDown = nil
			door:SetNotSolid(false)
			door:DrawShadow(true)
			door:SetNoDraw(false)
		end
	end)
end

-- A function to permanently kill a player.
function Schema:PermaKillPlayer(player, ragdoll)
	if (player:Alive()) then
		player:Kill()
		ragdoll = player:GetRagdollEntity()
	end

	local inventory = player:GetInventory()
	local cash = player:GetCash()
	local info = {}

	if (!player:GetCharacterData("permakilled")) then
		info.inventory = inventory
		info.cash = cash

		if (!IsValid(ragdoll)) then
			info.entity = ents.Create("cw_belongings")
		end

		hook.Run("PlayerAdjustPermaKillInfo", player, info)

		for k, v in pairs(info.inventory) do
			local itemTable = item.FindByID(k)

			if (itemTable and itemTable.allowStorage == false) then
				info.inventory[k] = nil
			end
		end

		player:SetCharacterData("permakilled", true)
		player:SetNetVar("permaKilled", true)
		player:SetCharacterData("inventory", {}, true)
		player:SetCharacterData("cash", 0, true)

		if (!IsValid(ragdoll)) then
			if (table.Count(info.inventory) > 0 or info.cash > 0) then
				info.entity:SetData(info.inventory, info.cash)
				info.entity:SetPos(player:GetPos() + Vector(0, 0, 48))
				info.entity:Spawn()
			else
				info.entity:Remove()
			end
		else
			ragdoll.areBelongings = true
			ragdoll.cwInventory = info.inventory
			ragdoll.cash = info.cash
		end

		cw.player:SaveCharacter(player)
	end
end

-- A function to tie or untie a player.
function Schema:TiePlayer(player, isTied, reset, combine)
	if (isTied) then
		if (combine) then
			player:SetNetVar("tied", 2)
		else
			player:SetNetVar("tied", 1)
		end
	else
		player:SetNetVar("tied", 0)
	end

	if (isTied) then
		cw.player:DropWeapons(player)
		cw.core:PrintLog(LOGTYPE_GENERIC, player:Name().." has been tied.")

		player:Flashlight(false)
		player:StripWeapons()
	elseif (!reset) then
		if (player:Alive() and !player:IsRagdolled()) then
			cw.player:LightSpawn(player, true, true)
		end

		cw.core:PrintLog(LOGTYPE_GENERIC, player:Name().." has been untied.")
	end
end
