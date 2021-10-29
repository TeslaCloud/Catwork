--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

library.New("lang", cw)

local stored = cw.lang.stored or {}
cw.lang.stored = stored

local fileList = cw.lang.fileList or {}
cw.lang.fileList = fileList

CW_LANGUAGE_CLASS = {__index = CW_LANGUAGE_CLASS}

function CW_LANGUAGE_CLASS:Add(identifier, value)
	self[identifier] = value
end

--[[
	@codebase Shared
	@details Get the language table for the given language (or create if it doesn't exist.)
	@param String The language to get the table for.
	@returns The language table for the given language.
--]]
function cw.lang:GetTable(name)
	if (!stored[name]) then
		stored[name] = cw.core:NewMetaTable(
			CW_LANGUAGE_CLASS
		)
	end

	return stored[name]
end

--[[
	@codebase Shared
	@details Get the table of all the languages.
	@returns The table containing all the languages.
--]]
function cw.lang:GetAll()
	return stored
end

function cw.lang:Add(language, fileName)
	if (!fileList[language]) then
		fileList[language] = {}
	end

	table.insert(fileList[language], fileName)
end

function cw.lang:Set(language) end

--[[
	@codebase Shared
	@details Get the language string for the given identifier.
	@param String The language which table to search.
	@param String The identifier to search for.
	@param Various A list of arguments to replace in the string.
	@returns The final string for the given identifier.
--]]
function cw.lang:GetString(language, identifier, arguments)
	local langString = nil
	arguments = arguments or {}

	if (stored[language]) then
		langString = stored[language][identifier]
	end

	if (!langString) then
		langString = stored["en"][identifier] or identifier
	end

	for k, v in pairs(arguments) do
		langString = string.gsub(langString, "#"..k, tostring(v), 1)
	end

	langString = langString:Replace(";", "")

	return langString
end

if (CLIENT) then
	function L(identifier)
		if (!identifier) then return "" end

		local lang = GetConVar("gmod_language"):GetString()
		local args = {}

		-- Get all the arguments.
		if (string.find(identifier, ";")) then
			args = string.Explode(",", identifier)

			local colon = args[1]:find(":")

			if (colon) then
				-- The first result will always be the base identifier.
				identifier = args[1]:sub(1, colon - 1)
				args[1] = args[1]:sub(colon + 1, args[1]:len())
			end
		end

		return cw.lang:GetString(lang, identifier, args)
	end

	surface.bTranslating = surface.bTranslating or true

	--[[
		This is to stop our overrides from parsing translations, we
		don't want certain things like the chatbox to be translated.
	--]]
	function surface.NoTranslate(bValue)
		surface.bTranslating = !bValue
	end

	surface.OldGetTextSize = surface.OldGetTextSize or surface.GetTextSize

	function surface.GetTextSize(sText)
		if (surface.bTranslating) then
			sText = cw.lang:TranslateText(sText)
		end

		return surface.OldGetTextSize(sText)
	end

	-- Explicit mode. This will attempt to translate the given text regardless of anything else.
	function cw.lang:TranslateText(sText)
		local phrases = string.FindAll(sText, "#[%w_.]+")
		local translations = {}

		for k, v in ipairs(phrases) do
			local phraseEnd = nil
			local colonDetected = false

			if (sText:sub(v[3] + 1, v[3] + 1) == ":") then
				phraseEnd = sText:find(";", v[2])
				colonDetected = true
			end

			if (!phraseEnd and !colonDetected) then
				phraseEnd = sText:find(" ", v[2])

				if (!phraseEnd) then
					phraseEnd = v[3]
				else
					phraseEnd = phraseEnd - 1
				end
			elseif (!phraseEnd and colonDetected) then
				phraseEnd = v[3]
			end

			translations[#translations + 1] = L(sText:sub(v[2], phraseEnd))
			phrases[k] = sText:sub(v[2], phraseEnd)
		end

		for k, v in ipairs(translations) do
			sText = sText:Replace(phrases[k], v)
		end

		return sText
	end

	surface.OldDrawText = surface.OldDrawText or surface.DrawText

	--[[
		Overwrite the way the surface library draws text,
		this way we can put translations into anything that uses this,
		like draw.SimpleText, etc.

		This will give us control over basically every text drawn
		with Lua outside of Derma.
	--]]
	function surface.DrawText(sText)
		if (surface.bTranslating) then
			sText = cw.lang:TranslateText(sText)
		end

		return surface.OldDrawText(sText)
	end

	local PANEL_META = FindMetaTable("Panel")

	PANEL_META.OldSetText = PANEL_META.OldSetText or PANEL_META.SetText

	-- Overwrite the way panels set their text, this way we can stick our translations in.
	function PANEL_META:SetText(sText)
		if (string.sub(sText, 1, 1) == "#" and surface.bTranslating) then
			local phraseName = sText
			local translated = L(sText)

			if (translated != sText and !self.AllowInput) then
				sText = translated
			elseif (translated != text and self.AllowInput) then
				sText = string.gsub(sText, "#", "")
			end

			self.__PhraseName = sText
		end

		return self:OldSetText(sText)
	end
else
	--[[
		Simply get the identifier with any arguments to send to clients.

		Since translation is done by player, we let clientside handle this,
		so we network the raw identifier with any arguments and let the client parse it.
	--]]
	function L(player, identifier, ...)
		local arguments = {...}

		-- In case the format L(identifier, ...) is used.
		if (isstring(player)) then
			if (identifier) then
				table.insert(arguments, 1, identifier)
			end

			identifier = player
		end

		if (identifier) then
			local text = "#"..identifier

			--[[
				We do this to provide backcompat for the
				few translations that were actually done serverside.

				This is also a way nicer way to do things, but
				you need to remember this is ONLY available serverside.

				Clientside needs to manually concat arguments.
			--]]
			if (arguments) then
				text = text..":"

				for k, v in ipairs(arguments) do
					text = text..v

					if (k < #arguments) then
						text = text..","
					end
				end

				text = text..";"
			end

			return text
		end
	end
end

util.IncludeDirectory("language/", true);
