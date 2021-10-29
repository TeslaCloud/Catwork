--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

library.New("setting", cw)

cw.setting.stored = cw.setting.stored or {}

-- A function to add a number slider setting.
function cw.setting:AddNumberSlider(category, text, conVar, minimum, maximum, decimals, toolTip, Condition)
//	local index = string.lower(string.gsub(category.."|"..text, " ", "_"))
	local index = conVar

	self.stored[index] = {
		Condition = Condition,
		category = category,
		decimals = decimals,
		toolTip = toolTip,
		maximum = maximum,
		minimum = minimum,
		conVar = conVar,
		class = "numberSlider",
		text = text
	}

	return index
end

-- A function to add a multi-choice setting.
function cw.setting:AddMultiChoice(category, text, conVar, options, toolTip, Condition)
//	local index = string.lower(string.gsub(category.."|"..text, " ", "_"))
	local index = conVar

	if (options) then
		table.sort(options, function(a, b) return a < b; end)
	else
		options = {}
	end

	self.stored[index] = {
		Condition = Condition,
		category = category,
		toolTip = toolTip,
		options = options,
		conVar = conVar,
		class = "multiChoice",
		text = text
	}

	return index
end

-- A function to add a number wang setting.
function cw.setting:AddNumberWang(category, text, conVar, minimum, maximum, decimals, toolTip, Condition)
//	local index = string.lower(string.gsub(category.."|"..text, " ", "_"))
	local index = conVar

	self.stored[index] = {
		Condition = Condition,
		category = category,
		decimals = decimals,
		toolTip = toolTip,
		maximum = maximum,
		minimum = minimum,
		conVar = conVar,
		class = "numberWang",
		text = text
	}

	return index
end

-- A function to add a text entry setting.
function cw.setting:AddTextEntry(category, text, conVar, toolTip, Condition)
//	local index = string.lower(string.gsub(category.."|"..text, " ", "_"))
	local index = conVar

	self.stored[index] = {
		Condition = Condition,
		category = category,
		toolTip = toolTip,
		conVar = conVar,
		class = "textEntry",
		text = text
	}

	return index
end

-- A function to add a check box setting.
function cw.setting:AddCheckBox(category, text, conVar, toolTip, Condition)
//	local index = string.lower(string.gsub(category.."|"..text, " ", "_"))
	local index = conVar

	self.stored[index] = {
		Condition = Condition,
		category = category,
		toolTip = toolTip,
		conVar = conVar,
		class = "checkBox",
		text = text
	}

	return index
end

-- A function to add a color mixer setting.
function cw.setting:AddColorMixer(category, text, conVar, toolTip, Condition)
//	local index = string.lower(string.gsub(category.."|"..text, " ", "_"))
	local index = conVar

	self.stored[index] = {
		Condition = Condition,
		category = category,
		toolTip = toolTip,
		conVar = conVar,
		class = "colorMixer",
		text = text
	}

	return index
end

-- A function to remove a setting by its index.
function cw.setting:RemoveByIndex(index)
	self.stored[index] = nil
end

-- A function to remove a setting by its convar.
function cw.setting:RemoveByConVar(conVar)
	for k, v in pairs(self.stored) do
		if (v.conVar == conVar) then
			self.stored[k] = nil
		end
	end
end

-- A function to remove a setting.
function cw.setting:Remove(category, text, class, conVar)
	for k, v in pairs(self.stored) do
		if ((!category or v.category == category)
		and (!conVar or v.conVar == conVar)
		and (!class or v.class == class)
		and (!text or v.text == text)) then
			self.stored[k] = nil
		end
	end
end

function cw.setting:AddSettings()
	local langTable = {}

	for k, v in pairs(cw.lang:GetAll()) do
		langTable[v.name] = k
	end

	local themeTable = {}

	for k, v in pairs(cw.theme:GetAll()) do
		themeTable[k] = k
	end

	local frameworkStr = "#Framework"
	local chatBoxStr = "#ChatBox"
	local themeStr = "#Theme"
	local adminESP = "#AdminESP"

	cw.setting:AddNumberSlider(frameworkStr, "#HeadbobAmount", "cwHeadbobScale", 0, 1, 1, "#HeadbobAmountDesc")
	cw.setting:AddNumberSlider(frameworkStr, "Громкость музыки", "nombat_volume", 0, 100, 1, "Громкость фоновой и боевой музыки.")

	cw.setting:AddCheckBox(frameworkStr, "#EnableConsoleLog", "cwShowLog", "#EnableConsoleLogDesc", function()
		return cw.player:IsAdmin(cw.client)
	end)

	cw.setting:AddCheckBox(frameworkStr, "#TwelveHourClock", "cwTwelveHourClock", "#TwelveHourClockDesc")
	cw.setting:AddCheckBox(frameworkStr, "#ShowBars", "cwTopBars", "#ShowBarsDesc")
	cw.setting:AddCheckBox(frameworkStr, "#EnableHints", "cwShowHints", "#EnableHintsDesc")
	cw.setting:AddMultiChoice(frameworkStr, "#Language", "gmod_language", langTable, "#LangDesc")
	cw.setting:AddCheckBox(frameworkStr, "#EnableVignette", "cwShowVignette", "#EnableVignetteDesc")

	cw.setting:AddMultiChoice(themeStr, themeStr, "cwActiveTheme", themeTable, "#ThemeDesc", function ()
		return (config.Get("modify_themes"):GetBoolean())
	end)

	//Schemas can re-add the stuff that was here.

	cw.setting:AddCheckBox(adminESP, "#EnableAdminESP", "cwAdminESP", "#EnableAdminESPDesc", function()
		return cw.player:IsAdmin(cw.client)
	end)

	cw.setting:AddCheckBox(adminESP, "#DrawESPBars", "cwESPBars", "#DrawESPBarsDesc", function()
		return cw.player:IsAdmin(cw.client)
	end)

	cw.setting:AddCheckBox(adminESP, "#ShowItemEntities", "cwItemESP", "#ShowItemEntitiesDesc", function()
		return cw.player:IsAdmin(cw.client)
	end)

	cw.setting:AddCheckBox(adminESP, "#ShowSalesmenEntities", "cwSaleESP", "#ShowSalesmenEntitiesDesc", function()
		return cw.player:IsAdmin(cw.client)
	end)

	cw.setting:AddCheckBox(adminESP, "Show Static Props", "cwPropESP", "Whether or not to show all static props.", function()
		return cw.player:IsAdmin(cw.client)
	end)

	cw.setting:AddNumberSlider(adminESP, "#ESPInterval", "cwESPTime", 0, 2, 0, "#ESPIntervalDesc", function()
		return cw.player:IsAdmin(cw.client)
	end)
end
