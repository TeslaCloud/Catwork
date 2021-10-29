--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

CreateFont = CreateFont or surface.CreateFont

function surface.CreateFont(...)
	cw.fonts:Add(...)
end

library.New("fonts", cw)

cw.fonts.stored = cw.fonts.stored or {}
cw.fonts.sizes = cw.fonts.sizes or {}

-- A function to add a new font to the system.
function cw.fonts:Add(name, fontTable, bForce)
	if (self.stored[name] and !bForce) then return end

	fontTable.extended = true; -- Force the font to load all characters.
	self.stored[name] = fontTable
	CreateFont(name, self.stored[name])
end

-- A function to find a font by name.
function cw.fonts:FindByName(name)
	return self.stored[name]
end

-- A function to grab a font by size (creating what doesn't exist.)
function cw.fonts:GetSize(name, size)
	local fontKey = name..size

	if (self.sizes[fontKey]) then
		return fontKey
	end

	if (!self.stored[name]) then
		return name
	end

	self.sizes[fontKey] = table.Copy(self.stored[name])
	self.sizes[fontKey].size = size

	CreateFont(fontKey, self.sizes[fontKey])
	return fontKey
end

-- A function to grab a font by multiplier.
function cw.fonts:GetMultiplied(name, multiplier)
	local fontTable = self:FindByName(name)
	if (fontTable == nil) then return name; end

	return self:GetSize(name, fontTable.size * multiplier)
end

cw.fonts:Add("cwMainText",
{
	font		= "Arial",
	size		= cw.core:FontScreenScale(7),
	weight		= 700,
	antialiase	= true,
	additive 	= false,
	extended	= true
})
cw.fonts:Add("cwESPText",
{
	font		= "Arial",
	size		= cw.core:FontScreenScale(5.5),
	weight		= 700,
	antialiase	= true,
	additive 	= false,
	extended 	= true
})
cw.fonts:Add("cwTooltip",
{
	font		= "Arial",
	size		= cw.core:FontScreenScale(5),
	weight		= 700,
	antialiase	= true,
	additive 	= false,
	extended	= true
})
cw.fonts:Add("cw.menuTextBig",
{
	font		= "Arial",
	size		= cw.core:FontScreenScale(18),
	weight		= 700,
	antialiase	= true,
	additive 	= false,
	extended 	= true
})
cw.fonts:Add("cw.menuTextTiny",
{
	font		= "Arial",
	size		= cw.core:FontScreenScale(7),
	weight		= 700,
	antialiase	= true,
	additive 	= false,
	extended	= true
})
cw.fonts:Add("cwInfoTextFont",
{
	font		= "Arial",
	size		= cw.core:FontScreenScale(6),
	weight		= 700,
	antialiase	= true,
	additive 	= false,
	extended	= true
})
cw.fonts:Add("cw.menuTextHuge",
{
	font		= "Arial",
	size		= cw.core:FontScreenScale(30),
	weight		= 700,
	antialiase	= true,
	additive 	= false,
	extended	= true
})
cw.fonts:Add("cw.menuTextSmall",
{
	font		= "Arial",
	size		= cw.core:FontScreenScale(10),
	weight		= 700,
	antialiase	= true,
	additive 	= false,
	extended	= true
})
cw.fonts:Add("cwIntroTextBig",
{
	font		= "Arial",
	size		= cw.core:FontScreenScale(18),
	weight		= 700,
	antialiase	= true,
	additive 	= false,
	extended	= true
})
cw.fonts:Add("cwIntroTextTiny",
{
	font		= "Arial",
	size		= cw.core:FontScreenScale(9),
	weight		= 700,
	antialiase	= true,
	additive 	= false,
	extended	= true
})
cw.fonts:Add("cwIntroTextSmall",
{
	font		= "Arial",
	size		= cw.core:FontScreenScale(7),
	weight		= 700,
	antialiase	= true,
	additive 	= false,
	extended	= true
})
cw.fonts:Add("cwLarge3D2D",
{
	font		= "Arial",
	size		= cw.core:GetFontSize3D(),
	weight		= 700,
	antialiase	= true,
	additive 	= false,
	extended 	= true
})
cw.fonts:Add("cwScoreboardName",
{
	font		= "Arial",
	size		= cw.core:FontScreenScale(7),
	weight		= 600,
	antialiase	= true,
	additive 	= false,
	extended 	= true
})
cw.fonts:Add("cwScoreboardDesc",
{
	font		= "Arial",
	size		= cw.core:FontScreenScale(5),
	weight		= 600,
	antialiase	= true,
	additive 	= false,
	extended 	= true
})
cw.fonts:Add("cwCinematicText",
{
	font		= "Trebuchet",
	size		= cw.core:FontScreenScale(8),
	weight		= 700,
	antialiase	= true,
	additive 	= false,
	extended 	= true
})
cw.fonts:Add("cwChatSyntax",
{
	font		= "Courier New",
	size		= cw.core:FontScreenScale(7),
	weight		= 600,
	antialiase	= true,
	additive 	= false,
	extended 	= true
})
