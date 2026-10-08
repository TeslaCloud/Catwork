--- Defines the client-side `cw.fonts` library, which creates fonts and makes resized copies of them on demand.
--
-- `surface.CreateFont` is replaced to go through `cw.fonts:Add`, with the engine function kept as the global
-- `CreateFont`, so that `cw.fonts:GetSize` and `cw.fonts:GetMultiplied` can return any font at another size. The file
-- also creates Catwork's own fonts, such as `cwMainText` and `cw.menuTextBig`.

CreateFont = CreateFont or surface.CreateFont

--- Creates a font through `cw.fonts:Add`, replacing the engine's `surface.CreateFont`.
--
-- Fonts created this way can be resized with `cw.fonts:GetSize`. A font name that
-- already exists is not created again. The engine function is kept as the global
-- `CreateFont`.
-- @param ... [Any The font name and font data `Map`, as for the engine function]
function surface.CreateFont(...)
  cw.fonts:Add(...)
end

library.New('fonts', cw)

cw.fonts.stored = cw.fonts.stored or {}
cw.fonts.sizes = cw.fonts.sizes or {}

--- Creates a font and stores its data so other sizes of it can be made.
--
-- `extended` is always turned on so the font loads every character. Does nothing
-- if the font already exists, unless `bForce` is set.
--
-- ```
-- cw.fonts:Add('cwMyFont', {
--   font = 'Roboto',
--   size = 18,
--   weight = 500
-- })
-- ```
--
-- @param name [String Name of the font]
-- @param fontTable [Map Font data as taken by the engine's `surface.CreateFont`]
-- @param bForce=nil [Boolean Whether to recreate a font that already exists]
function cw.fonts:Add(name, fontTable, bForce)
  if self.stored[name] and !bForce then return end

  fontTable.extended = true -- Force the font to load all characters.
  self.stored[name] = fontTable
  CreateFont(name, self.stored[name])
end

--- Returns the data of a font added with `cw.fonts:Add`.
-- @param name [String Name of the font]
-- @return [Map The font data, or `nil` if the font was not added]
function cw.fonts:FindByName(name)
  return self.stored[name]
end

--- Returns a copy of a font at another size, creating it the first time.
--
-- ```
-- draw.SimpleText('Hello', cw.fonts:GetSize('cwMainText', 24), x, y)
-- ```
--
-- @param name [String Name of a font added with `cw.fonts:Add`]
-- @param size [Number Font size]
-- @return [String Name of the sized font (`name` followed by `size`), or `name` if the font
-- was not added]
-- @see cw.fonts:GetMultiplied
function cw.fonts:GetSize(name, size)
  local fontKey = name..size

  if self.sizes[fontKey] then
    return fontKey
  end

  if !self.stored[name] then
    return name
  end

  self.sizes[fontKey] = table.Copy(self.stored[name])
  self.sizes[fontKey].size = size

  CreateFont(fontKey, self.sizes[fontKey])
  return fontKey
end

--- Returns a copy of a font with its size multiplied, creating it the first time.
-- @param name [String Name of a font added with `cw.fonts:Add`]
-- @param multiplier [Number Factor applied to the font's size]
-- @return [String Name of the sized font, or `name` if the font was not added]
-- @see cw.fonts:GetSize
function cw.fonts:GetMultiplied(name, multiplier)
  local fontTable = self:FindByName(name)
  if fontTable == nil then return name end

  return self:GetSize(name, fontTable.size * multiplier)
end

cw.fonts:Add('cwMainText',
{
  font		= 'Arial',
  size		= cw.core:FontScreenScale(7),
  weight = 700,
  antialiase = true,
  additive = false,
  extended = true
})
cw.fonts:Add('cwESPText',
{
  font		= 'Arial',
  size		= cw.core:FontScreenScale(5.5),
  weight = 700,
  antialiase = true,
  additive 	= false,
  extended 	= true
})
cw.fonts:Add('cwTooltip',
{
  font		= 'Arial',
  size		= cw.core:FontScreenScale(5),
  weight = 700,
  antialiase = true,
  additive = false,
  extended = true
})
cw.fonts:Add('cw.menuTextBig',
{
  font		= 'Arial',
  size		= cw.core:FontScreenScale(18),
  weight = 700,
  antialiase = true,
  additive 	= false,
  extended 	= true
})
cw.fonts:Add('cw.menuTextTiny',
{
  font		= 'Arial',
  size		= cw.core:FontScreenScale(7),
  weight = 700,
  antialiase = true,
  additive = false,
  extended = true
})
cw.fonts:Add('cwInfoTextFont',
{
  font		= 'Arial',
  size		= cw.core:FontScreenScale(6),
  weight = 700,
  antialiase = true,
  additive = false,
  extended = true
})
cw.fonts:Add('cw.menuTextHuge',
{
  font		= 'Arial',
  size		= cw.core:FontScreenScale(30),
  weight = 700,
  antialiase = true,
  additive = false,
  extended = true
})
cw.fonts:Add('cw.menuTextSmall',
{
  font		= 'Arial',
  size		= cw.core:FontScreenScale(10),
  weight = 700,
  antialiase = true,
  additive = false,
  extended = true
})
cw.fonts:Add('cwIntroTextBig',
{
  font		= 'Arial',
  size		= cw.core:FontScreenScale(18),
  weight = 700,
  antialiase = true,
  additive = false,
  extended = true
})
cw.fonts:Add('cwIntroTextTiny',
{
  font		= 'Arial',
  size		= cw.core:FontScreenScale(9),
  weight = 700,
  antialiase = true,
  additive = false,
  extended = true
})
cw.fonts:Add('cwIntroTextSmall',
{
  font		= 'Arial',
  size		= cw.core:FontScreenScale(7),
  weight = 700,
  antialiase = true,
  additive = false,
  extended = true
})
cw.fonts:Add('cwLarge3D2D',
{
  font		= 'Arial',
  size		= cw.core:GetFontSize3D(),
  weight = 700,
  antialiase = true,
  additive 	= false,
  extended 	= true
})
cw.fonts:Add('cwScoreboardName',
{
  font		= 'Arial',
  size		= cw.core:FontScreenScale(7),
  weight = 600,
  antialiase = true,
  additive 	= false,
  extended 	= true
})
cw.fonts:Add('cwScoreboardDesc',
{
  font		= 'Arial',
  size		= cw.core:FontScreenScale(5),
  weight = 600,
  antialiase = true,
  additive 	= false,
  extended 	= true
})
cw.fonts:Add('cwCinematicText',
{
  font		= 'Trebuchet',
  size		= cw.core:FontScreenScale(8),
  weight = 700,
  antialiase = true,
  additive 	= false,
  extended 	= true
})
cw.fonts:Add('cwChatSyntax',
{
  font		= 'Courier New',
  size		= cw.core:FontScreenScale(7),
  weight = 600,
  antialiase = true,
  additive 	= false,
  extended 	= true
})
