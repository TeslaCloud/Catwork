--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

cw.core = cw.core or {}
library = library or {}

hook.Remove("PostDrawEffects", "RenderWidgets")
hook.Remove("PlayerTick", "TickWidgets")

do
	-- ID's should not have any of those characters.
	local blockedChars = {
		"'", "\"", "\\", "/", "^",
		":", ".", ";", "&", ",", "%"
	}

	function string.MakeID(str)
		str = str:utf8lower()
		str = str:gsub(" ", "_")

		for k, v in ipairs(blockedChars) do
			str = str:Replace(v, "")
		end

		return str
	end
end

function util.Validate(...)
	local args = {...}

	if (#args <= 0) then return false end

	for k, v in ipairs(args) do
		if (!IsValid(v)) then
			return false
		end
	end

	return true
end

-- A function to convert a single hexadecimal digit to decimal.
function util.HexToDec(hex)
	hex = hex:lower()

	local hexDigits = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"}
	local negative = false

	if (hex:StartWith("-")) then
		hex = hex:sub(2, 2)
		negative = true
	end

	for k, v in ipairs(hexDigits) do
		if (v == hex) then
			if (!negative) then
				return k - 1
			else
				return -(k - 1)
			end
		end
	end

	ErrorNoHalt("[Catwork] '"..hex.."' is not a hexadecimal number!")
	return 0
end

function util.HexToDecimal(hex)
	local sum = 0
	local chars = table.Reverse(string.Explode("", hex))
	local idx = 1

	for i = 0, hex:len() - 1 do
		sum = sum + util.HexToDec(chars[idx]) * math.pow(16, i)
		idx = idx + 1
	end

	return sum
end

-- A function to convert hexadecimal color to a color structure.
function util.HexToColor(hex)
	if (hex:StartWith("#")) then
		hex = hex:sub(2, hex:len())
	end

	if (hex:len() != 6 and hex:len() != 8) then
		return Color(255, 255, 255)
	end

	local hexColors = {}
	local initLen = hex:len() / 2

	for i = 1, hex:len() / 2 do
		table.insert(hexColors, hex:sub(1, 2))

		if (i != initLen) then
			hex = hex:sub(3, hex:len())
		end
	end

	local color = {}

	for k, v in ipairs(hexColors) do
		local chars = table.Reverse(string.Explode("", v))
		local sum = 0

		for i = 1, 2 do
			sum = sum + util.HexToDec(chars[i]) * math.pow(16, i - 1)
		end

		table.insert(color, sum)
	end

	return Color(color[1], color[2], color[3], (color[4] or 255))
end

-- A helper function to get lowercase name of the data type.
function typeof(obj)
	return string.lower(type(obj))
end

local colors = {
	aliceblue 		= Color(240, 248, 255),
	antiquewhite 	= Color(250, 235, 215),
	aqua 			= Color(0, 255, 255),
	aquamarine 		= Color(127, 255, 212),
	azure		 	= Color(240, 255, 255),
	beige 			= Color(245, 245, 220),
	bisque 			= Color(255, 228, 196),
	black 			= Color(0, 0, 0),
	blanchedalmond 	= Color(255, 235, 205),
	blue 			= Color(0, 0, 255),
	blueviolet 		= Color(138, 43, 226),
	brown 			= Color(165, 42, 42),
	burlywood	 	= Color(222, 184, 135),
	cadetblue 		= Color(95, 158, 160),
	chartreuse 		= Color(127, 255, 0),
	chocolate 		= Color(210, 105, 30),
	coral			= Color(255, 127, 80),
	cornflowerblue 	= Color(100, 149, 237),
	cornsilk 		= Color(255, 248, 220),
	crimson 		= Color(220, 20, 60),
	cyan 			= Color(0, 255, 255),
	darkblue 		= Color(0, 0, 139),
	darkcyan 		= Color(0, 139, 139),
	darkgoldenrod 	= Color(184, 134, 11),
	darkgray 		= Color(169, 169, 169),
	darkgreen 		= Color(0, 100, 0),
	darkgrey 		= Color(169, 169, 169),
	darkkhaki 		= Color(189, 183, 107),
	darkmagenta 	= Color(139, 0, 139),
	darkolivegreen 	= Color(85, 107, 47),
	darkorange 		= Color(255, 140, 0),
	darkorchid 		= Color(153, 50, 204),
	darkred 		= Color(139, 0, 0),
	darksalmon 		= Color(233, 150, 122),
	darkseagreen 	= Color(143, 188, 143),
	darkslateblue 	= Color(72, 61, 139),
	darkslategray 	= Color(47, 79, 79),
	darkslategrey 	= Color(47, 79, 79),
	darkturquoise 	= Color(0, 206, 209),
	darkviolet 		= Color(148, 0, 211),
	deeppink 		= Color(255, 20, 147),
	deepskyblue 	= Color(0, 191, 255),
	dimgray 		= Color(105, 105, 105),
	dimgrey 		= Color(105, 105, 105),
	dodgerblue 		= Color(30, 144, 255),
	firebrick 		= Color(178, 34, 34),
	floralwhite 	= Color(255, 250, 240),
	forestgreen 	= Color(34, 139, 34),
	fuchsia 		= Color(255, 0, 255),
	gainsboro 		= Color(220, 220, 220),
	ghostwhite 		= Color(248, 248, 255),
	gold 			= Color(255, 215, 0),
	goldenrod 		= Color(218, 165, 32),
	gray 			= Color(128, 128, 128),
	grey 			= Color(128, 128, 128),
	green 			= Color(0, 128, 0),
	greenyellow 	= Color(173, 255, 47),
	honeydew 		= Color(240, 255, 240),
	hotpink 		= Color(255, 105, 180),
	indianred 		= Color(205, 92, 92),
	indigo 			= Color(75, 0, 130),
	ivory 			= Color(255, 255, 240),
	khaki 			= Color(240, 230, 140),
	lavender 		= Color(230, 230, 250),
	lavenderblush 	= Color(255, 240, 245),
	lawngreen 		= Color(124, 252, 0),
	lemonchiffon 	= Color(255, 250, 205),
	lightblue 		= Color(173, 216, 230),
	lightcoral 		= Color(240, 128, 128),
	lightcyan 		= Color(224, 255, 255),
	lightgoldenrodyellow = Color(250, 250, 210),
	lightgray 		= Color(211, 211, 211),
	lightgreen 		= Color(144, 238, 144),
	lightgrey 		= Color(211, 211, 211),
	lightpink 		= Color(255, 182, 193),
	lightsalmon 	= Color(255, 160, 122),
	lightseagreen 	= Color(32, 178, 170),
	lightskyblue 	= Color(135, 206, 250),
	lightslategray 	= Color(119, 136, 153),
	lightslategrey 	= Color(119, 136, 153),
	lightsteelblue 	= Color(176, 196, 222),
	lightyellow 	= Color(255, 255, 224),
	lime 			= Color(0, 255, 0),
	limegreen 		= Color(50, 205, 50),
	linen 			= Color(250, 240, 230),
	magenta 		= Color(255, 0, 255),
	maroon 			= Color(128, 0, 0),
	mediumaquamarine = Color(102, 205, 170),
	mediumblue 		= Color(0, 0, 205),
	mediumorchid 	= Color(186, 85, 211),
	mediumpurple 	= Color(147, 112, 219),
	mediumseagreen 	= Color(60, 179, 113),
	mediumslateblue = Color(123, 104, 238),
	mediumspringgreen = Color(0, 250, 154),
	mediumturquoise = Color(72, 209, 204),
	mediumvioletred = Color(199, 21, 133),
	midnightblue 	= Color(25, 25, 112),
	mintcream 		= Color(245, 255, 250),
	mistyrose 		= Color(255, 228, 225),
	moccasin 		= Color(255, 228, 181),
	navajowhite 	= Color(255, 222, 173),
	navy		 	= Color(0, 0, 128),
	oldlace 		= Color(253, 245, 230),
	olive 			= Color(128, 128, 0),
	olivedrab 		= Color(107, 142, 35),
	orange 			= Color(255, 165, 0),
	orangered 		= Color(255, 69, 0),
	orchid 			= Color(218, 112, 214),
	palegoldenrod 	= Color(238, 232, 170),
	palegreen 		= Color(152, 251, 152),
	paleturquoise 	= Color(175, 238, 238),
	palevioletred 	= Color(219, 112, 147),
	papayawhip 		= Color(255, 239, 213),
	peachpuff 		= Color(255, 218, 185),
	peru 			= Color(205, 133, 63),
	pink 			= Color(255, 192, 203),
	plum 			= Color(221, 160, 221),
	powderblue 		= Color(176, 224, 230),
	purple 			= Color(128, 0, 128),
	red 			= Color(255, 0, 0),
	rosybrown 		= Color(188, 143, 143),
	royalblue 		= Color(65, 105, 225),
	saddlebrown 	= Color(139, 69, 19),
	salmon 			= Color(250, 128, 114),
	sandybrown 		= Color(244, 164, 96),
	seagreen 		= Color(46, 139, 87),
	seashell 		= Color(255, 245, 238),
	sienna 			= Color(160, 82, 45),
	silver 			= Color(192, 192, 192),
	skyblue 		= Color(135, 206, 235),
	slateblue 		= Color(106, 90, 205),
	slategray 		= Color(112, 128, 144),
	slategrey 		= Color(112, 128, 144),
	snow 			= Color(255, 250, 250),
	springgreen 	= Color(0, 255, 127),
	steelblue 		= Color(70, 130, 180),
	tan 			= Color(210, 180, 140),
	teal 			= Color(0, 128, 128),
	thistle			= Color(216, 191, 216),
	tomato 			= Color(255, 99, 71),
	turquoise 		= Color(64, 224, 208),
	violet 			= Color(238, 130, 238),
	wheat 			= Color(245, 222, 179),
	white 			= Color(255, 255, 255),
	whitesmoke 		= Color(245, 245, 245),
	yellow 			= Color(255, 255, 0),
	yellowgreen 	= Color(154, 205, 50)
}

cw.oldColor = cw.oldColor or Color

function Color(r, g, b, a)
	if (isstring(r)) then
		if (r:StartWith("#")) then
			return util.HexToColor(r)
		elseif (colors[r:lower()]) then
			return colors[r:lower()]
		else
			return Color(255, 255, 255)
		end
	else
		return cw.oldColor(r, g, b, a)
	end
end

-- A function to determine whether vector from A to B intersects with a
-- vector from C to D.
function util.VectorsIntersect(vFrom, vTo, vFrom2, vTo2)
	local d1, d2, a1, a2, b1, b2, c1, c2

	a1 = vTo.y - vFrom.y
	b1 = vFrom.x - vTo.x
	c1 = (vTo.x * vFrom.y) - (vFrom.x * vTo.y)

	d1 = (a1 * vFrom2.x) + (b1 * vFrom2.y) + c1
	d2 = (a1 * vTo2.x) + (b1 * vTo2.y) + c1

	if (d1 > 0 and d2 > 0) then return false end
	if (d1 < 0 and d2 < 0) then return false end

	a2 = vTo2.y - vFrom2.y
	b2 = vFrom2.x - vTo2.x
	c2 = (vTo2.x * vFrom2.y) - (vFrom2.x * vTo2.y)

	d1 = (a2 * vFrom.x) + (b2 * vFrom.y) + c2
	d2 = (a2 * vTo.x) + (b2 * vTo.y) + c2

	if (d1 > 0 and d2 > 0) then return false end
	if (d1 < 0 and d2 < 0) then return false end

	-- Vectors are collinear or intersect.
	-- No need for further checks.
	return true
end

-- A function to determine whether a 2D point is inside of a 2D polygon.
function util.VectorIsInPoly(point, polyVertices)
	if (!isvector(point) or !istable(polyVertices) or !isvector(polyVertices[1])) then
		return
	end

	local intersections = 0

	for k, v in ipairs(polyVertices) do
		local nextVert

		if (k < #polyVertices) then
			nextVert = polyVertices[k + 1]
		elseif (k == #polyVertices) then
			nextVert = polyVertices[1]
		end

		if (nextVert and util.VectorsIntersect(point, Vector(99999, 99999, 0), v, nextVert)) then
			intersections = intersections + 1
		end
	end

	-- Check whether number of intersections is even or odd.
	-- If it's odd then the point is inside the polygon.
	if (intersections % 2 == 0) then
		return false
	else
		return true
	end
end

do
	local colorMeta = FindMetaTable("Color")

	function colorMeta:Darken(amt)
		return Color(
			math.Clamp(self.r - amt, 0, 255),
			math.Clamp(self.g - amt, 0, 255),
			math.Clamp(self.b - amt, 0, 255),
			self.a
		)
	end

	function colorMeta:Lighten(amt)
		return Color(
			math.Clamp(self.r + amt, 0, 255),
			math.Clamp(self.g + amt, 0, 255),
			math.Clamp(self.b + amt, 0, 255),
			self.a
		)
	end
end

-- A function to do C-style formatted prints.
function printf(str, ...)
	print(Format(str, ...))
end

-- Let's face it. When you develop for C++ you kinda want to do this in Lua.
function cout(...)
	print(...)
end

-- A function to select a random player.
function player.Random()
	local allPly = player.GetAll()

	if (#allPly > 0) then
		return allPly[math.random(1, #allPly)]
	end
end

function string.FindAll(str, pattern)
	if (!str or !pattern) then return end

	local hits = {}
	local lastPos = 1

	while (true) do
		local startPos, endPos = string.find(str, pattern, lastPos)

		if (!startPos) then
			break
		end

		table.insert(hits, {str:sub(startPos, endPos), startPos, endPos})

		lastPos = endPos + 1
	end

	return hits
end

-- A function to throw an awesome colored print.
function cw.core:Print(message, color)
	color = color or Color(255, 255, 255)

	if (type(message) == "table") then
		message = table.concat(message, " ")
	end

	if (type(message) != "string") then
		return
	elseif (!message or message == "" or message == " ") then
		return
	end

	MsgC(Color(100, 255, 100), "[Catwork] ")
	MsgC(color, message.."\n")
end

-- A function to print red 'error' print.
function cw.core:Error(message)
	if (cw.LogLevel >= 1) then
		self:Print(message, Color(255, 0, 0))
	end
end

-- A function to print yellow 'warning' print.
function cw.core:Warning(message)
	if (cw.LogLevel >= 2) then
		self:Print(message, Color(255, 255, 0))
	end
end

-- A function to print green 'good' print.
function cw.core:Good(message)
	if (cw.LogLevel >= 3) then
		self:Print(message, Color(0, 255, 0))
	end
end

-- A function to print pink developer print.
function cw.core:Debug(message)
	if (cw.LogLevel >= 4) then
		self:Print(message, Color(255, 0, 255))
	end
end

function cw.core:Spam(message)
	if (cw.LogLevel >= 5) then
		self:Print(message, Color(255, 0, 255))
	end
end

--[[
	@codebase Shared
	@details A function to get whether two tables are equal.
	@param Table The first unique table to compare.
	@param Table The second unique table to compare.
	@returns Bool Whether or not the tables are equal.
--]]
function cw.core:AreTablesEqual(tableA, tableB)
	if (istable(tableA) and istable(tableB)) then
		if (#tableA != #tableB) then
			return false
		end

		for k, v in pairs(tableA) do
			if (istable(v) and !self:AreTablesEqual(v, tableB[k])) then
				return false
			end

			if (v != tableB[k]) then
				return false
			end
		end

		return true
	end

	return false
end

--[[
	@codebase Shared
	@details A function to get whether a weapon is a default weapon.
	@param Entity The weapon entity.
	@returns Bool Whether or not the weapon is a default weapon.
--]]
function cw.core:IsDefaultWeapon(weapon)
	if (IsValid(weapon)) then
		local class = string.lower(weapon:GetClass())
		if (class == "weapon_physgun" or class == "gmod_physcannon"
		or class == "gmod_tool") then
			return true
		end
	end

	return false
end

-- A function to format cash.
function cw.core:FormatCash(amount, singular, lowerName)
	local formatSingular = cw.option:GetKey("format_singular_cash")
	local formatCash = cw.option:GetKey("format_cash")
	local cashName = cw.option:GetKey("name_cash")

	if (CLIENT) then
		cashName = cw.lang:TranslateText(cashName)

		if (lowerName) then
			cashName = cashName:utf8lower()
		end
	end

	local realAmount = tostring(math.Round(amount))

	if (singular) then
		return self:Replace(self:Replace(formatSingular, "%n", cashName), "%a", realAmount)
	else
		return self:Replace(self:Replace(formatCash, "%n", cashName), "%a", realAmount)
	end
end

function table.SafeMerge(to, from)
	local oldIndex, oldIndex2 = to.__index, from.__index

	to.__index = nil
	from.__index = nil

	table.Merge(to, from)

	to.__index = oldIndex
	from.__index = oldIndex2
end

-- A function to create a new library.
function library.New(strName, tParent)
	tParent = tParent or _G

	tParent[strName] = tParent[strName] or {}

	return tParent[strName]
end

-- A function to get an existing library.
function library.Get(strName, tParent)
	tParent = tParent or _G

	return tParent[strName] or library.New(strName, tParent)
end

-- Set library table's Metatable so that we can call it like a function.
setmetatable(library, {__call = function(tab, strName, tParent) return tab.Get(strName, tParent) end})

-- A function to create a new class. Supports constructors and inheritance.
function library.NewClass(strName, tParent, CExtends)
	local class = {
		-- Same as "new ClassName" in C++
		__call = function(obj, ...)
			local newObj = {}

			-- Set new object's meta table and copy the data from original class to new object.
			setmetatable(newObj, obj)
			table.SafeMerge(newObj, obj)

			-- If there is a base class, call their constructor.
			if (obj.BaseClass) then
				pcall(obj.BaseClass, newObj, ...)
			end

			-- If there is a constructor - call it.
			if (obj[strName]) then
				local success, value = pcall(obj[strName], newObj, ...)

				if (!success) then
					ErrorNoHalt("["..strName.."] Class constructor has failed to run!\n")
					ErrorNoHalt(value.."\n")
				end
			end

			-- Return our newly generated object.
			return newObj
		end
	}

	-- If this class is based off some other class - copy it's parent's data.
	if (istable(CExtends)) then
		table.SafeMerge(class, CExtends)
	end

	-- Create the actual class table.
	local obj = library.New(strName, (tParent or _G))
	obj.ClassName = strName
	obj.BaseClass = CExtends or false

	return setmetatable((tParent or _G)[strName], class)
end

function Class(strName, CExtends, tParent)
	return library.NewClass(strName, tParent, CExtends)
end

-- Alias because class could get easily confused with player class.
Meta = Class

-- Also make an alias that looks like other programming languages.
class = Class

-- A function to convert a string to a color.
function cw.core:StringToColor(text)
	local explodedData = string.Explode(",", text)
	local color = Color(255, 255, 255, 255)

	if (explodedData[1]) then
		color.r = tonumber(explodedData[1]:Trim()) or 255
	end

	if (explodedData[2]) then
		color.g = tonumber(explodedData[2]:Trim()) or 255
	end

	if (explodedData[3]) then
		color.b = tonumber(explodedData[3]:Trim()) or 255
	end

	if (explodedData[4]) then
		color.a = tonumber(explodedData[4]:Trim()) or 255
	end

	return color
end

-- A function to get a log type color.
function cw.core:GetLogTypeColor(logType)
	local logTypes = {
		Color(255, 50, 50, 255),
		Color(255, 150, 0, 255),
		Color(255, 200, 0, 255),
		Color(0, 150, 255, 255),
		Color(0, 255, 125, 255)
	}

	return logTypes[logType] or logTypes[5]
end

--[[
	@codebase Shared
	@details A function to get the kernel version.
	@returns String The kernel version.
--]]
function cw.core:GetVersion()
	return cw.KernelVersion
end

--[[
	@codebase Shared
	@details A function to get the kernel version and build.
	@returns String The kernel version and build concatenated.
--]]
function cw.core:GetVersionBuild()
	return cw.KernelVersion
end

--[[
	@codebase Shared
	@details A function to get the schema folder.
	@returns String The schema folder.
--]]
function cw.core:GetSchemaFolder(sFolderName)
	if (sFolderName) then
		return cw.Schema.."/schema/"..sFolderNane
	else
		return cw.Schema
	end
end

--[[
	@codebase Shared
	@details A function to get the schema gamemode path.
	@returns String The schema gamemode path.
--]]
function cw.core:GetSchemaGamemodePath()
	return cw.Schema
end

--[[
	@codebase Shared
	@details A function to get the Clockwork folder.
	@returns String The Clockwork folder.
--]]
function cw.core:GetClockworkFolder()
	return (string.gsub(cw.ClockworkFolder, "gamemodes/", ""))
end

--[[
	@codebase Shared
	@details A function to get the Clockwork path.
	@returns String The Clockwork path.
--]]
function cw.core:GetClockworkPath()
	return (string.gsub(cw.ClockworkFolder, "gamemodes/", "").."/gamemode/core")
end

-- A function to get the path to GMod.
function cw.core:GetPathToGMod()
	return util.RelativePathToFull("."):sub(1, -2)
end

-- A function to convert a string to a boolean.
function cw.core:ToBool(text)
	if (text == "true" or text == "yes" or text == "1") then
		return true
	else
		return false
	end
end

-- A function to remove text from the end of a string.
function cw.core:RemoveTextFromEnd(text, toRemove)
	local toRemoveLen = string.utf8len(toRemove)
	if (string.utf8sub(text, -toRemoveLen) == toRemove) then
		return (string.utf8sub(text, 0, -(toRemoveLen + 1)))
	else
		return text
	end
end

-- A function to split a string.
function cw.core:SplitString(text, interval)
	local length = string.utf8len(text)
	local baseTable = {}
	local i = 0

	while (i * interval < length) do
		baseTable[i + 1] = string.utf8sub(text, i * interval + 1, (i + 1) * interval)
		i = i + 1
	end

	return baseTable
end

-- A function to get whether a letter is a vowel.
function cw.core:IsVowel(letter)
	letter = string.lower(letter)
	return (letter == "a" or letter == "e" or letter == "i"
	or letter == "o" or letter == "u")
end

-- A function to pluralize some text.
function cw.core:Pluralize(text)
	return text
end

-- A function to serialize a table.
function cw.core:Serialize(tTable, bForceJSON)
	if (istable(tTable)) then
		local bSuccess, value

		if (!bForceJSON) then
			bSuccess, value = pcall(pon.encode, tTable)
		end

		if (!bSuccess or bForceJSON) then
			bSuccess, value = pcall(util.TableToJSON, tTable)

			if (!bSuccess) then
				ErrorNoHalt("[Catwork] Failed to serialize a table!\n")
				ErrorNoHalt(value.."\n")
				debug.Trace()

				return ""
			end
		end

		return value
	else
		print("[Catwork] You must serialize a table, not "..type(tTable).."!")

		return ""
	end
end

-- A function to deserialize a string.
function cw.core:Deserialize(strData, bForceJSON)
	if (isstring(strData)) then
		local bSuccess, value

		if (!bForceJSON) then
			bSuccess, value = pcall(pon.decode, strData)
		end

		if (!bSuccess or bForceJSON) then
			bSuccess, value = pcall(util.JSONToTable, strData)

			if (!bSuccess) then
				ErrorNoHalt("[Catwork] Failed to deserialize a string!\n")
				ErrorNoHalt(tostring(value).."\n")
				debug.Trace()

				return {}
			end
		end

		return value
	else
		print("[Catwork] You must deserialize a string, not "..type(strData).."!")

		return {}
	end
end

-- A function to get ammo information from a weapon.
function cw.core:GetAmmoInformation(weapon)
	if (IsValid(weapon) and IsValid(weapon.Owner) and weapon.Primary and weapon.Secondary) then
		if (!weapon.AmmoInfo) then
			weapon.AmmoInfo = {
				primary = {
					ammoType = weapon:GetPrimaryAmmoType(),
					clipSize = weapon.Primary.ClipSize
				},
				secondary = {
					ammoType = weapon:GetSecondaryAmmoType(),
					clipSize = weapon.Secondary.ClipSize
				}
			}
		end

		weapon.AmmoInfo.primary.ownerAmmo = weapon.Owner:GetAmmoCount(weapon.AmmoInfo.primary.ammoType)
		weapon.AmmoInfo.primary.clipBullets = weapon:Clip1()
		weapon.AmmoInfo.primary.doesNotShoot = (weapon.AmmoInfo.primary.clipBullets == -1)
		weapon.AmmoInfo.secondary.ownerAmmo = weapon.Owner:GetAmmoCount(weapon.AmmoInfo.secondary.ammoType)
		weapon.AmmoInfo.secondary.clipBullets = weapon:Clip2()
		weapon.AmmoInfo.secondary.doesNotShoot = (weapon.AmmoInfo.secondary.clipBullets == -1)

		if (!weapon.AmmoInfo.primary.doesNotShoot and weapon.AmmoInfo.primary.ownerAmmo > 0) then
			weapon.AmmoInfo.primary.ownerClips = math.ceil(weapon.AmmoInfo.primary.clipSize / weapon.AmmoInfo.primary.ownerAmmo)
		else
			weapon.AmmoInfo.primary.ownerClips = 0
		end

		if (!weapon.AmmoInfo.secondary.doesNotShoot and weapon.AmmoInfo.secondary.ownerAmmo > 0) then
			weapon.AmmoInfo.secondary.ownerClips = math.ceil(weapon.AmmoInfo.secondary.clipSize / weapon.AmmoInfo.secondary.ownerAmmo)
		else
			weapon.AmmoInfo.secondary.ownerClips = 0
		end

		return weapon.AmmoInfo
	end
end

function util.WaitForEntity(entIndex, callback, delay, waitTime)
	local entity = Entity(entIndex)

	if (!IsValid(entity)) then
		local timerName = CurTime().."_EntWait"

		timer.Create(timerName, delay or 0, waitTime or 100, function()
			local entity = Entity(entIndex)

			if (IsValid(entity)) then
				callback(entity)

				timer.Remove(timerName)
			end
		end)
	else
		callback(entity)
	end
end

-- Awful code because I'm out of time and Catwork is obsolete.
if (CLIENT) then
	netstream.Hook("PlayerModelChanged", function(nPlyIndex, sNewModel, sOldModel)
		util.WaitForEntity(nPlyIndex, function(player)
			hook.Run("PlayerModelChanged", player, sNewModel, sOldModel)
		end)
	end)
end

function cw.core:LoadSchema()
	cw.core.schemaStartTime = cw.startTime or os.clock()
	local startTime = cw.core.schemaStartTime

	self:Debug("Schema loading benchmark: Schema loading started...")

	Schema = Schema or plugin.New()

	local directory = cw.Schema.."/schema"

	if (SERVER) then
		local schemaInfo = self:GetSchemaGamemodeInfo()
			table.Merge(Schema, schemaInfo)
		CW_SCRIPT_SHARED.schemaData = schemaInfo
	elseif (CW_SCRIPT_SHARED.schemaData) then
		table.Merge(Schema, CW_SCRIPT_SHARED.schemaData)
	else
		MsgC(Color(255, 100, 0, 255), "\n[Catwork] The schema has no "..schemaFolder..".ini!\n")
	end

	self:Debug("Generated schema info table at "..math.Round(os.clock() - startTime, 3)..".")

	self:Debug(directory.."/sh_schema.lua")

	if (_file.Exists(directory.."/sh_schema.lua", "LUA")) then
		AddCSLuaFile(directory.."/sh_schema.lua")
		include(directory.."/sh_schema.lua")
	else
		MsgC(Color(255, 100, 0, 255), "\n[Catwork] The schema has no sh_schema.lua.\n")
	end

	self:Debug("Loaded sh_schema and rest of the files at "..math.Round(os.clock() - startTime, 3)..".")

	plugin.IncludeExtras(directory)

	self:Debug("Included extras at "..math.Round(os.clock() - startTime, 3)..".")

	plugin.CacheFunctions(Schema)

	self:Debug("Cached schema hooks at "..math.Round(os.clock() - startTime, 3)..".")

	cw.core.schemaStartTime = nil

	directory = self:RemoveTextFromEnd(directory, "/schema")
	plugin.IncludePlugins(directory)

	self:Debug("Finished loading at "..math.Round(os.clock() - startTime, 3)..".")
end

-- A function to explode a string by tags.
function cw.core:ExplodeByTags(text, seperator, open, close, hide)
	local results = {}
	local current = ""
	local tag = nil

	for i = 1, #text do
		local character = string.utf8sub(text, i, i)

		if (!tag) then
			if (character == open) then
				if (!hide) then
					current = current..character
				end

				tag = true
			elseif (character == seperator) then
				results[#results + 1] = current; current = ""
			else
				current = current..character
			end
		else
			if (character == close) then
				if (!hide) then
					current = current..character
				end

				tag = nil
			else
				current = current..character
			end
		end
	end

	if (current != "") then
		results[#results + 1] = current
	end

	return results
end

-- A function to modify a physical description.
function cw.core:ModifyPhysDesc(description)

	-- Clamp russian physDesc length to 256.
	if (string.find(description, "[абвгдеёжзийклмнопрстуфхцчшщъьыэюяАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЬЫЭЮЯ]") != nil) then
		if (string.utf8len(description) > 256) then
			return string.utf8sub(description, 1, 253).."..."
		end
	end

	if (string.utf8len(description) <= 1024) then
		if (!string.find(string.utf8sub(description, -2), "%p")) then
			return description.."."
		else
			return description
		end
	else
		return string.utf8sub(description, 1, 1021).."..."
	end
end

do
	local MAGIC_CHARACTERS = "([%(%)%.%%%+%-%*%?%[%^%$])"

	-- A function to replace something in text without pattern matching.
	function cw.core:Replace(text, find, replace)
		return (text:gsub(find:gsub(MAGIC_CHARACTERS, "%%%1"), replace))
	end
end

-- A function to create a new meta table.
function cw.core:NewMetaTable(baseTable)
	local object = {}
		setmetatable(object, baseTable)
		baseTable.__index = baseTable
	return object
end

-- A function to make a proxy meta table.
function cw.core:MakeProxyTable(baseTable, baseClass, proxy)
	baseTable[proxy] = {}

	baseTable.__index = function(object, key)
		local value = rawget(object, key)

		if (type(value) == "function") then
			return value
		elseif (object.__proxy) then
			return object:__proxy(key)
		else
			return object[proxy][key]
		end
	end

	baseTable.__newindex = function(object, key, value)
		if (type(value) != "function") then
			object[proxy][key] = value
			return
		end

		rawset(object, key, value)
	end

	for k, v in pairs(baseTable) do
		if (type(v) != "function" and k != proxy) then
			baseTable[proxy][k] = v
			baseTable[k] = nil
		end
	end

	setmetatable(baseTable, baseClass)
end

-- A function to set whether a string should be in camel case.
function cw.core:SetCamelCase(text, bCamelCase)
	if (bCamelCase) then
		return string.gsub(text, "^.", string.lower)
	else
		return string.gsub(text, "^.", string.upper)
	end
end

-- A function to add files to the content download.
function cw.core:AddDirectory(directory, bRecursive)
	if (string.utf8sub(directory, -1) == "/") then
		directory = directory.."*.*"
	end

	local files, folders = _file.Find(directory, "GAME", "namedesc")
	local rawDirectory = string.match(directory, "(.*)/").."/"

	for k, v in ipairs(files) do
		self:AddFile(rawDirectory..v)
	end

	if (bRecursive) then
		for k, v in ipairs(folders) do
			if (v != ".." and v != ".") then
				self:AddDirectory(rawDirectory..v, true)
			end
		end
	end
end

-- A function to add a file to the content download.
function cw.core:AddFile(fileName)
	resource.AddFile(fileName)
end

-- A function to include a file based on it's prefix.
function util.Include(strFile)
	if (SERVER) then
		if (string.find(strFile, "cl_")) then
			AddCSLuaFile(strFile)
		elseif (string.find(strFile, "sv_") or string.find(strFile, "init.lua")) then
			return include(strFile)
		else
			AddCSLuaFile(strFile)

			return include(strFile)
		end
	else
		if (!string.find(strFile, "sv_") and strFile != "init.lua" and !strFile:EndsWith("/init.lua")) then
			return include(strFile)
		end
	end
end

-- A function to add a file to clientside downloads list based on it's prefix.
function util.AddCSLuaFile(strFile)
	if (SERVER) then
		if (string.find(strFile, "sh_") or string.find(strFile, "cl_") or string.find(strFile, "shared.lua")) then
			AddCSLuaFile(strFile)
		end
	end
end

-- A function to include all files in a directory.
function util.IncludeDirectory(strDirectory, strBase, bIsRecursive)
	if (strBase) then
		if (isbool(strBase)) then
			strBase = "catwork/gamemode/core/"
		elseif (!strBase:EndsWith("/")) then
			strBase = strBase.."/"
		end

		strDirectory = strBase..strDirectory
	end

	if (!strDirectory:EndsWith("/")) then
		strDirectory = strDirectory.."/"
	end

	if (bIsRecursive) then
		local files, folders = _file.Find(strDirectory.."*", "LUA", "namedesc")

		-- First include the files.
		for k, v in ipairs(files) do
			if (v:GetExtensionFromFilename() == "lua") then
				util.Include(strDirectory..v)
			end
		end

		-- Then include all directories.
		for k, v in ipairs(folders) do
			util.IncludeDirectory(strDirectory..v, bIsRecursive)
		end
	else
		local files, _ = _file.Find(strDirectory.."*.lua", "LUA", "namedesc")

		for k, v in ipairs(files) do
			util.Include(strDirectory..v)
		end
	end
end

-- A function to include files in a directory.
function cw.core:IncludeDirectory(directory, bFromBase)
	return util.IncludeDirectory(directory, bFromBase)
end

-- A function to include a prefixed _file.
function cw.core:IncludePrefixed(fileName)
	return util.Include(fileName)
end

-- A function to include plugins in a directory.
function cw.core:IncludePlugins(directory, bFromBase)
	if (bFromBase) then
		directory = "catwork/"..directory
	end

	if (string.sub(directory, -1) != "/") then
		directory = directory.."/"
	end

	local files, pluginFolders = _file.Find(directory.."*", "LUA", "namedesc")

	for k, v in ipairs(files) do
		if (v:EndsWith(".lua")) then
			plugin.Include(directory..v)
		end
	end

	for k, v in ipairs(pluginFolders) do
		if (v != ".." and v != ".") then
			plugin.Include(directory..v.."/plugin")
		end
	end

	return true
end

-- A function to run a function on the next frame.
function cw.core:OnNextFrame(name, Callback)
	return timer.Create(name, FrameTime(), 1, Callback)
end

-- A function to get whether a player has access to an object.
function cw.core:HasObjectAccess(player, object)
	local hasAccess = false

	if (object.access) then
		if (cw.player:HasAnyFlags(player, object.access)) then
			hasAccess = true
		end
	end

	if (object.factions) then
		local faction = player:GetFaction()

		if (table.HasValue(object.factions, faction)) then
			hasAccess = true
		end
	end

	if (object.classes) then
		local team = player:Team()
		local class = cw.class:FindByID(team)

		if (class) then
			if (table.HasValue(object.classes, team)
			or table.HasValue(object.classes, class.name)) then
				hasAccess = true
			end
		end
	end

	if (!object.access and !object.factions
	and !object.classes) then
		hasAccess = true
	end

	if (object.blacklist) then
		local team = player:Team()
		local class = cw.class:FindByID(team)
		local faction = player:GetFaction()

		if (table.HasValue(object.blacklist, faction)) then
			hasAccess = false
		elseif (class) then
			if (table.HasValue(object.blacklist, team)
			or table.HasValue(object.blacklist, class.name)) then
				hasAccess = false
			end
		else
			for k, v in pairs(object.blacklist) do
				if (type(v) == "string") then
					if (cw.player:HasAnyFlags(player, v)) then
						hasAccess = false

						break
					end
				end
			end
		end
	end

	if (object.HasObjectAccess) then
		return object:HasObjectAccess(player, hasAccess)
	end

	return hasAccess
end

-- A function to get the sorted commands.
function cw.core:GetSortedCommands()
	local commands = {}
	local source = cw.command:GetAll()

	for k, v in pairs(source) do
		commands[#commands + 1] = k
	end

	table.sort(commands, function(a, b)
		return a < b
	end)

	return commands
end

-- A function to zero a number to an amount of digits.
function cw.core:ZeroNumberToDigits(number, digits)
	return string.rep("0", math.Clamp(digits - string.utf8len(tostring(number)), 0, digits))..tostring(number)
end

-- A function to get a short CRC from a value.
function cw.core:GetShortCRC(value)
	return math.ceil(util.CRC(value) / 100000)
end

-- A function to validate a table's keys.
function cw.core:ValidateTableKeys(baseTable)
	for i = 1, #baseTable do
		if (!baseTable[i]) then
			table.remove(baseTable, i)
		end
	end
end

-- A function to get the map's physics entities.
function cw.core:GetPhysicsEntities()
	local entities = {}

	for k, v in ipairs(ents.FindByClass("prop_physics_multiplayer")) do
		if (IsValid(v)) then
			table.insert(entities, v)
		end
	end

	for k, v in ipairs(ents.FindByClass("prop_physics")) do
		if (IsValid(v)) then
			table.insert(entities, v)
		end
	end

	return entities
end

-- A function to create a multicall table (by Deco Da Man).
function cw.core:CreateMulticallTable(baseTable, object)
	local metaTable = getmetatable(baseTable) or {}
		function metaTable.__index(baseTable, key)
			return function(baseTable, ...)
				for k, v in pairs(baseTable) do
					object[key](v, ...)
				end
			end
		end
	setmetatable(baseTable, metaTable)

	return baseTable
end

-- A function to create fake damage info.
function cw.core:FakeDamageInfo(damage, inflictor, attacker, position, damageType, damageForce)
	local damageInfo = DamageInfo()
	local realDamage = math.ceil(math.max(damage, 0))

	damageInfo:SetDamagePosition(position)
	damageInfo:SetDamageForce(Vector() * damageForce)
	damageInfo:SetDamageType(damageType)
	damageInfo:SetInflictor(inflictor)
	damageInfo:SetAttacker(attacker)
	damageInfo:SetDamage(realDamage)

	return damageInfo
end

-- A function to unpack a color.
function cw.core:UnpackColor(color)
	return color.r, color.g, color.b, color.a
end

-- A function to parse data in text.
function cw.core:ParseData(text)
	local classes = {"%^", "%!"}

	for k, v in ipairs(classes) do
		for key in string.gmatch(text, v.."(.-)"..v) do
			local lower = false
			local amount

			if (string.utf8sub(key, 1, 1) == "(" and string.utf8sub(key, -1) == ")") then
				lower = true
				amount = tonumber(string.utf8sub(key, 2, -2))
			else
				amount = tonumber(key)
			end

			if (amount) then
				text = string.gsub(text, v..string.gsub(key, "([%(%)])", "%%%1")..v, tostring(self:FormatCash(amount, k == 2, lower)))
			end
		end
	end

	for k in string.gmatch(text, "%*(.-)%*") do
		k = string.gsub(k, "[%(%)]", "")

		if (k != "") then
			text = string.gsub(text, "%*%("..k.."%)%*", tostring(cw.option:GetKey(k, true)))
			text = string.gsub(text, "%*"..k.."%*", tostring(cw.option:GetKey(k)))
		end
	end

	if (CLIENT) then
		for k in string.gmatch(text, ":(.-):") do
			if (k != "" and input.LookupBinding(k)) then
				text = self:Replace(text, ":"..k..":", "<"..string.upper(tostring(input.LookupBinding(k)))..">")
			end
		end
	end

	return config.Parse(text)
end

function cw.core:SetSharedVar(key, val, sendTo)
	return netvars.SetNetVar(key, val, sendTo)
end

function cw.core:GetSharedVar(key, default)
	return netvars.GetNetVar(key, default)
end

timer.Create("cw.HalfSecondTimer", 0.5, 0, function()
	hook.Run("HalfSecond")
end)

timer.Create("cw.OneSecondTimer", 1, 0, function()
	hook.Run("OneSecond")
end)

timer.Create("cw.OneMinuteTimer", 60, 0, function()
	hook.Run("OneMinute")
end)

timer.Create("LazyTick", 0.125, 0, function()
	hook.Run("LazyTick")
end)
