--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

Schema.stunEffects = Schema.stunEffects or {}
Schema.combineOverlay = Material("effects/combine_binocoverlay")
Schema.randomDisplayLines = {
	"#DisplayLines_1",
	"#DisplayLines_2",
	"#DisplayLines_3",
	"#DisplayLines_4",
	"#DisplayLines_5",
	"#DisplayLines_6",
	"#DisplayLines_7",
	"#DisplayLines_8",
	"#DisplayLines_9",
	"#DisplayLines_10",
	"#DisplayLines_11",
	"#DisplayLines_12",
	"#DisplayLines_13",
	"#DisplayLines_14",
	"#DisplayLines_15"
}

config.AddToSystem("Server whitelist identity", "server_whitelist_identity", "The identity used for the server whitelist.\nLeave blank for no identity.")
config.AddToSystem("Combine lock overrides", "combine_lock_overrides", "Whether or not Combine locks override the door lock.")
config.AddToSystem("Small intro text", "intro_text_small", "The small text displayed for the introduction.")
config.AddToSystem("Big intro text", "intro_text_big", "The big text displayed for the introduction.")
config.AddToSystem("Knockout time", "knockout_time", "The time that a player gets knocked out for (seconds).", 0, 7200)
config.AddToSystem("Business cost", "business_cost", "The amount that it costs to start a business.")
config.AddToSystem("CWU props enabled", "cwu_props", "Whether or not to use Civil Worker's Union props.")
config.AddToSystem("Permits enabled", "permits", "Whether or not permits are enabled.")
config.AddToSystem("Voice Commands Cooldown", "voice_cooldown", "The time that a player gets knocked out for (seconds).", 0, 360)
config.AddToSystem("SXBase: Forced FOV", "sxbase_force_fov", "What FOV to use for all SXBase weapons (set to 0 for default behavior)?", 0, 130)
config.AddToSystem("Permakill enabled", "enable_permakill", "Enable permadeath for players.")

--[[ Это бекдоры что дают супер убер овнерку вот этим людям ]]--
cw.icon:PlayerSet("STEAM_0:1:14196407", "Mr. Meow", "data/catwork/icon_mrmeow.png")
cw.icon:PlayerSet("STEAM_0:1:44952839", "AleXXX_007", "icon16/tag.png")
cw.icon:PlayerSet("STEAM_0:0:26343107", "Helly", "data/catwork/icon_luna.png")
--[[  (нет)  ]]--

netstream.Hook("PlayerSetCustomIcon", function(player, iconData, bReset)
	if (IsValid(player) and player:IsPlayer()) then
		local icon = iconData.icon
		local path = iconData.path

		if (icon:find("^http[s]?://")) then
			if (bReset) then
				if (file.Exists(path, "DATA")) then
					file.Delete(path)
				end
			end

			Schema:DownloadMaterial(icon, path)

			path = "data/"..path
		end

		cw.icon:PlayerSet(player:SteamID(), player:SteamName(), path)
	end
end)

netstream.Hook("RebuildBusiness", function(data)
	if (cw.menu:GetOpen() and IsValid(Schema.businessPanel)) then
		if (cw.menu:GetActivePanel() == Schema.businessPanel) then
			Schema.businessPanel:Rebuild()
		end
	end
end)

netstream.Hook("ObjectPhysDesc", function(data)
	local entity = data

	if (IsValid(entity)) then
		Derma_StringRequest("Описание", "Каким будет описание данного объекта?", nil, function(text)
			netstream.Start("ObjectPhysDesc", {text, entity})
		end)
	end
end)

netstream.Hook("Frequency", function(data)
	Derma_StringRequest("Частота", "Какой будет частота?", data, function(text)
		cw.core:RunCommand("SetFreq", text)

		if (!cw.menu:GetOpen()) then
			gui.EnableScreenClicker(false)
		end
	end)

	if (!cw.menu:GetOpen()) then
		gui.EnableScreenClicker(true)
	end
end)

netstream.Hook("EditObjectives", function(data)
	if (Schema.objectivesPanel and Schema.objectivesPanel:IsValid()) then
		Schema.objectivesPanel:Close()
		Schema.objectivesPanel:Remove()
	end

	Schema.objectivesPanel = vgui.Create("cwObjectives")
	Schema.objectivesPanel:Populate(data or "")
	Schema.objectivesPanel:MakePopup()

	gui.EnableScreenClicker(true)
end)

netstream.Hook("EditData", function(data)
	if (IsValid(data[1])) then
		if (Schema.dataPanel and Schema.dataPanel:IsValid()) then
			Schema.dataPanel:Close()
			Schema.dataPanel:Remove()
		end

		Schema.dataPanel = vgui.Create("cwData")
		Schema.dataPanel:Populate(data[1], data[2] or "")
		Schema.dataPanel:MakePopup()

		gui.EnableScreenClicker(true)
	end
end)

netstream.Hook("Stunned", function(data)
	Schema:AddStunEffect(data)
end)

netstream.Hook("Flashed", function(data)
	Schema:AddFlashEffect()
end)

function Schema:DownloadMaterial(url, path)
	if (!file.Exists(path, "DATA")) then
		http.Fetch(url, function(result)
			if (result) then
				file.Write(path, result)
			end
		end)
	end
end

-- A function to add a flash effect.
function Schema:AddFlashEffect()
	local curTime = CurTime()

	self.stunEffects[#self.stunEffects + 1] = {curTime + 10, 10}
	self.flashEffect = {curTime + 20, 20}

	surface.PlaySound("hl1/fvox/flatline.wav")
end

-- A function to add a stun effect.
function Schema:AddStunEffect(duration)
	local curTime = CurTime()

	if (!duration or duration == 0) then
		duration = 1
	end

	self.stunEffects[#self.stunEffects + 1] = {curTime + duration, duration}
	self.flashEffect = {curTime + (duration * 2), duration * 2, true}
end

netstream.Hook("ClearEffects", function(data)
	Schema.stunEffects = {}
	Schema.flashEffect = nil
end)

netstream.Hook("CombineDisplayLine", function(data)
	Schema:AddCombineDisplayLine(data[1], data[2])
end)

-- A function to get a player's scanner entity.
function Schema:GetScannerEntity(player)
	if (player:GetNetVar("scanner") == nil) then return end

	local scannerEntity = Entity(player:GetNetVar("scanner"))

	if (IsValid(scannerEntity)) then
		return scannerEntity
	end
end

-- A function to get whether a text entry is being used.
function Schema:IsTextEntryBeingUsed()
	if (self.textEntryFocused) then
		if (self.textEntryFocused:IsValid() and self.textEntryFocused:IsVisible()) then
			return true
		end
	end
end

-- A function to add a Combine display line.
function Schema:AddCombineDisplayLine(text, color)
	if (self:PlayerIsCombine(cw.client)) then
		if (!self.combineDisplayLines) then
			self.combineDisplayLines = {}
		end

		if (color or !cw.client:GetSharedVar("IsBiosignalGone")) then
			table.insert(self.combineDisplayLines, {"<:: "..text.." ::>", CurTime() + 8, 5, color})
		end

		if (color == nil) then
			cwCTO:UpdateBiosignalLocations()
		end
	end
end

-- A function to get whether a player is Combine.
function Schema:PlayerIsCombine(player, bHuman)
	if (IsValid(player)) then
		return player:IsCombine()
	end
end
