--- Defines the shared kernel: the `cw.core` library, the `library` and `Class` helpers and a set of global utility
-- functions.
--
-- `cw.core` holds the file and plugin includers (also exposed as `util.Include` and `util.IncludeDirectory`),
-- `cw.core:Serialize` and `cw.core:Deserialize`, console logging filtered by `cw.LogLevel`, and string, table and
-- color helpers. The file also replaces the engine `Color` so that it accepts hex strings and CSS color names, adds
-- helpers such as `string.MakeID`, `typeof` and `util.WaitForEntity`, and creates the timers that run the
-- `HalfSecond`, `OneSecond`, `OneMinute` and `LazyTick` hooks.

cw.core = cw.core or {}
library = library or {}

hook.Remove('PostDrawEffects', 'RenderWidgets')
hook.Remove('PlayerTick', 'TickWidgets')

do
  -- ID's should not have any of those characters.
  local blockedChars = {
    "'", '"', '\\', '/', '^',
    ':', '.', ';', '&', ',', '%'
  }

  --- Turns a string into an identifier.
  --
  -- Lowercases it (UTF-8 aware), replaces spaces with underscores and strips quotes, slashes and
  -- the characters `^ : . ; & , %`.
  --
  -- ```
  -- string.MakeID('Civil Protection') -- 'civil_protection'
  -- ```
  --
  -- @param str [String Text to convert]
  -- @return [String The identifier]
  function string.MakeID(str)
    str = str:utf8lower()
    str = str:gsub(' ', '_')

    for k, v in ipairs(blockedChars) do
      str = str:Replace(v, '')
    end

    return str
  end
end

--- Returns whether every argument is a valid object.
-- @param ... [Any Objects to check with `IsValid`]
-- @return [Boolean `true` if at least one argument was passed and all of them are valid]
function util.Validate(...)
  local args = { ... }

  if #args <= 0 then return false end

  for k, v in ipairs(args) do
    if !IsValid(v) then
      return false
    end
  end

  return true
end

--- Converts a single hexadecimal digit to a number.
--
-- A leading `-` makes the result negative. Prints an error and returns `0` when the character
-- is not a hexadecimal digit.
-- @param hex [String One hexadecimal digit, case-insensitive]
-- @return [Number The digit's value, 0 to 15]
-- @see util.HexToDecimal
function util.HexToDec(hex)
  hex = hex:lower()

  local hexDigits = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' }
  local negative = false

  if hex:StartsWith('-') then
    hex = hex:sub(2, 2)
    negative = true
  end

  for k, v in ipairs(hexDigits) do
    if v == hex then
      if !negative then
        return k - 1
      else
        return -(k - 1)
      end
    end
  end

  ErrorNoHalt("[Catwork] '"..hex.."' is not a hexadecimal number!")
  return 0
end

--- Converts a hexadecimal number string to a number.
-- @param hex [String Hexadecimal digits without a prefix, such as `'ff'`]
-- @return [Number The decimal value]
-- @see util.HexToDec
function util.HexToDecimal(hex)
  local sum = 0
  local chars = table.Reverse(string.Explode('', hex))
  local idx = 1

  for i = 0, hex:len() - 1 do
    sum = sum + util.HexToDec(chars[idx]) * math.pow(16, i)
    idx = idx + 1
  end

  return sum
end

--- Converts a hexadecimal color string to a color.
--
-- Accepts `RRGGBB` or `RRGGBBAA`, with or without a leading `#`. Any other length returns white.
--
-- ```
-- local red = util.HexToColor('#ff0000')
-- ```
--
-- @param hex [String The hexadecimal color]
-- @return [Color The color; alpha is 255 unless given]
function util.HexToColor(hex)
  if hex:StartsWith('#') then
    hex = hex:sub(2, hex:len())
  end

  if hex:len() != 6 and hex:len() != 8 then
    return Color(255, 255, 255)
  end

  local hexColors = {}
  local initLen = hex:len() / 2

  for i = 1, hex:len() / 2 do
    table.insert(hexColors, hex:sub(1, 2))

    if i != initLen then
      hex = hex:sub(3, hex:len())
    end
  end

  local color = {}

  for k, v in ipairs(hexColors) do
    local chars = table.Reverse(string.Explode('', v))
    local sum = 0

    for i = 1, 2 do
      sum = sum + util.HexToDec(chars[i]) * math.pow(16, i - 1)
    end

    table.insert(color, sum)
  end

  return Color(color[1], color[2], color[3], (color[4] or 255))
end

--- Returns the lowercase name of a value's type.
-- @param obj [Any The value to check]
-- @return [String The result of `type` in lowercase, such as `'player'` or `'string'`]
function typeof(obj)
  return string.lower(type(obj))
end

local colors = {
  aliceblue = Color(240, 248, 255),
  antiquewhite = Color(250, 235, 215),
  aqua = Color(0, 255, 255),
  aquamarine = Color(127, 255, 212),
  azure		 	= Color(240, 255, 255),
  beige 			= Color(245, 245, 220),
  bisque = Color(255, 228, 196),
  black = Color(0, 0, 0),
  blanchedalmond = Color(255, 235, 205),
  blue = Color(0, 0, 255),
  blueviolet = Color(138, 43, 226),
  brown = Color(165, 42, 42),
  burlywood	 	= Color(222, 184, 135),
  cadetblue 		= Color(95, 158, 160),
  chartreuse = Color(127, 255, 0),
  chocolate = Color(210, 105, 30),
  coral = Color(255, 127, 80),
  cornflowerblue = Color(100, 149, 237),
  cornsilk = Color(255, 248, 220),
  crimson = Color(220, 20, 60),
  cyan = Color(0, 255, 255),
  darkblue 		= Color(0, 0, 139),
  darkcyan 		= Color(0, 139, 139),
  darkgoldenrod = Color(184, 134, 11),
  darkgray = Color(169, 169, 169),
  darkgreen = Color(0, 100, 0),
  darkgrey = Color(169, 169, 169),
  darkkhaki = Color(189, 183, 107),
  darkmagenta = Color(139, 0, 139),
  darkolivegreen = Color(85, 107, 47),
  darkorange 		= Color(255, 140, 0),
  darkorchid 		= Color(153, 50, 204),
  darkred = Color(139, 0, 0),
  darksalmon = Color(233, 150, 122),
  darkseagreen = Color(143, 188, 143),
  darkslateblue 	= Color(72, 61, 139),
  darkslategray 	= Color(47, 79, 79),
  darkslategrey 	= Color(47, 79, 79),
  darkturquoise 	= Color(0, 206, 209),
  darkviolet = Color(148, 0, 211),
  deeppink = Color(255, 20, 147),
  deepskyblue = Color(0, 191, 255),
  dimgray 		= Color(105, 105, 105),
  dimgrey 		= Color(105, 105, 105),
  dodgerblue = Color(30, 144, 255),
  firebrick = Color(178, 34, 34),
  floralwhite 	= Color(255, 250, 240),
  forestgreen 	= Color(34, 139, 34),
  fuchsia = Color(255, 0, 255),
  gainsboro = Color(220, 220, 220),
  ghostwhite = Color(248, 248, 255),
  gold = Color(255, 215, 0),
  goldenrod = Color(218, 165, 32),
  gray 			= Color(128, 128, 128),
  grey 			= Color(128, 128, 128),
  green = Color(0, 128, 0),
  greenyellow = Color(173, 255, 47),
  honeydew = Color(240, 255, 240),
  hotpink = Color(255, 105, 180),
  indianred = Color(205, 92, 92),
  indigo = Color(75, 0, 130),
  ivory 			= Color(255, 255, 240),
  khaki 			= Color(240, 230, 140),
  lavender = Color(230, 230, 250),
  lavenderblush = Color(255, 240, 245),
  lawngreen = Color(124, 252, 0),
  lemonchiffon = Color(255, 250, 205),
  lightblue = Color(173, 216, 230),
  lightcoral = Color(240, 128, 128),
  lightcyan = Color(224, 255, 255),
  lightgoldenrodyellow = Color(250, 250, 210),
  lightgray = Color(211, 211, 211),
  lightgreen = Color(144, 238, 144),
  lightgrey 		= Color(211, 211, 211),
  lightpink 		= Color(255, 182, 193),
  lightsalmon = Color(255, 160, 122),
  lightseagreen = Color(32, 178, 170),
  lightskyblue = Color(135, 206, 250),
  lightslategray 	= Color(119, 136, 153),
  lightslategrey 	= Color(119, 136, 153),
  lightsteelblue 	= Color(176, 196, 222),
  lightyellow = Color(255, 255, 224),
  lime = Color(0, 255, 0),
  limegreen = Color(50, 205, 50),
  linen = Color(250, 240, 230),
  magenta 		= Color(255, 0, 255),
  maroon 			= Color(128, 0, 0),
  mediumaquamarine = Color(102, 205, 170),
  mediumblue = Color(0, 0, 205),
  mediumorchid 	= Color(186, 85, 211),
  mediumpurple 	= Color(147, 112, 219),
  mediumseagreen 	= Color(60, 179, 113),
  mediumslateblue = Color(123, 104, 238),
  mediumspringgreen = Color(0, 250, 154),
  mediumturquoise = Color(72, 209, 204),
  mediumvioletred = Color(199, 21, 133),
  midnightblue = Color(25, 25, 112),
  mintcream 		= Color(245, 255, 250),
  mistyrose 		= Color(255, 228, 225),
  moccasin = Color(255, 228, 181),
  navajowhite = Color(255, 222, 173),
  navy = Color(0, 0, 128),
  oldlace = Color(253, 245, 230),
  olive = Color(128, 128, 0),
  olivedrab = Color(107, 142, 35),
  orange = Color(255, 165, 0),
  orangered = Color(255, 69, 0),
  orchid = Color(218, 112, 214),
  palegoldenrod = Color(238, 232, 170),
  palegreen = Color(152, 251, 152),
  paleturquoise 	= Color(175, 238, 238),
  palevioletred 	= Color(219, 112, 147),
  papayawhip = Color(255, 239, 213),
  peachpuff = Color(255, 218, 185),
  peru 			= Color(205, 133, 63),
  pink 			= Color(255, 192, 203),
  plum 			= Color(221, 160, 221),
  powderblue = Color(176, 224, 230),
  purple = Color(128, 0, 128),
  red = Color(255, 0, 0),
  rosybrown 		= Color(188, 143, 143),
  royalblue 		= Color(65, 105, 225),
  saddlebrown = Color(139, 69, 19),
  salmon = Color(250, 128, 114),
  sandybrown = Color(244, 164, 96),
  seagreen 		= Color(46, 139, 87),
  seashell 		= Color(255, 245, 238),
  sienna 			= Color(160, 82, 45),
  silver 			= Color(192, 192, 192),
  skyblue 		= Color(135, 206, 235),
  slateblue 		= Color(106, 90, 205),
  slategray 		= Color(112, 128, 144),
  slategrey 		= Color(112, 128, 144),
  snow = Color(255, 250, 250),
  springgreen = Color(0, 255, 127),
  steelblue = Color(70, 130, 180),
  tan = Color(210, 180, 140),
  teal = Color(0, 128, 128),
  thistle			= Color(216, 191, 216),
  tomato 			= Color(255, 99, 71),
  turquoise = Color(64, 224, 208),
  violet = Color(238, 130, 238),
  wheat 			= Color(245, 222, 179),
  white 			= Color(255, 255, 255),
  whitesmoke = Color(245, 245, 245),
  yellow = Color(255, 255, 0),
  yellowgreen = Color(154, 205, 50)
}

cw.oldColor = cw.oldColor or Color

--- Creates a color from components, a hexadecimal string or a CSS color name.
--
-- Replaces the engine `Color`, which is kept as `cw.oldColor`. A string starting with `#` is
-- passed to `util.HexToColor`, a known CSS color name (such as `'tomato'`, case-insensitive)
-- returns that color, and any other string returns white.
--
-- ```
-- Color(255, 0, 0)
-- Color('#ff000080')
-- Color('steelblue')
-- ```
--
-- @param r [Number Red component 0 to 255, or a color string]
-- @param g [Number Green component; ignored for strings]
-- @param b [Number Blue component; ignored for strings]
-- @param a=255 [Number Alpha component; ignored for strings]
-- @return [Color The color]
function Color(r, g, b, a)
  if isstring(r) then
    if r:StartsWith('#') then
      return util.HexToColor(r)
    elseif colors[r:lower()] then
      return colors[r:lower()]
    else
      return Color(255, 255, 255)
    end
  else
    return cw.oldColor(r, g, b, a)
  end
end

--- Returns whether the line segment from A to B intersects the segment from C to D.
--
-- Only the `x` and `y` components are used. Collinear segments count as intersecting.
-- @param vFrom [Vector Start of the first segment]
-- @param vTo [Vector End of the first segment]
-- @param vFrom2 [Vector Start of the second segment]
-- @param vTo2 [Vector End of the second segment]
-- @return [Boolean Whether the segments intersect]
function util.VectorsIntersect(vFrom, vTo, vFrom2, vTo2)
  local d1, d2, a1, a2, b1, b2, c1, c2

  a1 = vTo.y - vFrom.y
  b1 = vFrom.x - vTo.x
  c1 = (vTo.x * vFrom.y) - (vFrom.x * vTo.y)

  d1 = (a1 * vFrom2.x) + (b1 * vFrom2.y) + c1
  d2 = (a1 * vTo2.x) + (b1 * vTo2.y) + c1

  if d1 > 0 and d2 > 0 then return false end
  if d1 < 0 and d2 < 0 then return false end

  a2 = vTo2.y - vFrom2.y
  b2 = vFrom2.x - vTo2.x
  c2 = (vTo2.x * vFrom2.y) - (vFrom2.x * vTo2.y)

  d1 = (a2 * vFrom.x) + (b2 * vFrom.y) + c2
  d2 = (a2 * vTo.x) + (b2 * vTo.y) + c2

  if d1 > 0 and d2 > 0 then return false end
  if d1 < 0 and d2 < 0 then return false end

  -- Vectors are collinear or intersect.
  -- No need for further checks.
  return true
end

--- Returns whether a 2D point lies inside a 2D polygon.
--
-- Casts a ray from the point and counts how many polygon edges it crosses, using only the `x`
-- and `y` components. Returns `nil` when the point is not a vector or the vertex list is empty.
-- @param point [Vector The point to test]
-- @param polyVertices [List<Vector> Polygon vertices in order; the last connects back to the first]
-- @return [Boolean Whether the point is inside the polygon]
-- @see util.VectorsIntersect
function util.VectorIsInPoly(point, polyVertices)
  if !isvector(point) or !istable(polyVertices) or !isvector(polyVertices[1]) then
    return
  end

  local intersections = 0

  for k, v in ipairs(polyVertices) do
    local nextVert

    if k < #polyVertices then
      nextVert = polyVertices[k + 1]
    elseif k == #polyVertices then
      nextVert = polyVertices[1]
    end

    if nextVert and util.VectorsIntersect(point, Vector(99999, 99999, 0), v, nextVert) then
      intersections = intersections + 1
    end
  end

  -- Check whether number of intersections is even or odd.
  -- If it's odd then the point is inside the polygon.
  if intersections % 2 == 0 then
    return false
  else
    return true
  end
end

do
  local colorMeta = FindMetaTable('Color')

  --- Returns a darker copy of the color.
  -- @param amt [Number Amount subtracted from each of the red, green and blue components]
  -- @return [Color The new color, clamped to 0 to 255, with the same alpha]
  -- @see Color:Lighten
  function colorMeta:Darken(amt)
    return Color(
      math.Clamp(self.r - amt, 0, 255),
      math.Clamp(self.g - amt, 0, 255),
      math.Clamp(self.b - amt, 0, 255),
      self.a
    )
  end

  --- Returns a lighter copy of the color.
  -- @param amt [Number Amount added to each of the red, green and blue components]
  -- @return [Color The new color, clamped to 0 to 255, with the same alpha]
  -- @see Color:Darken
  function colorMeta:Lighten(amt)
    return Color(
      math.Clamp(self.r + amt, 0, 255),
      math.Clamp(self.g + amt, 0, 255),
      math.Clamp(self.b + amt, 0, 255),
      self.a
    )
  end
end

--- Prints a C-style formatted string.
-- @param str [String Format string for `Format`]
-- @param ... [Any Values for the format string]
function printf(str, ...)
  print(Format(str, ...))
end

--- Prints its arguments; an alias of `print`.
-- @param ... [Any Values to print]
function cout(...)
  print(...)
end

--- Returns a random connected player.
-- @return [Player A random player, or `nil` when the server is empty]
function player.Random()
  local allPly = player.GetAll()

  if #allPly > 0 then
    return allPly[math.random(1, #allPly)]
  end
end

--- Finds every match of a pattern in a string.
--
-- Each hit is a list of `{ match, startPos, endPos }`. Returns `nil` when either argument is
-- missing.
-- @param str [String The string to search]
-- @param pattern [String Lua pattern to look for]
-- @return [List<List> The hits in order]
function string.FindAll(str, pattern)
  if !str or !pattern then return end

  local hits = {}
  local lastPos = 1

  while true do
    local startPos, endPos = string.find(str, pattern, lastPos)

    if !startPos then
      break
    end

    table.insert(hits, { str:sub(startPos, endPos), startPos, endPos })

    lastPos = endPos + 1
  end

  return hits
end

--- Prints a message to the console with a green `[Catwork]` prefix.
--
-- A table is joined with spaces first. Empty or non-string messages print nothing.
-- @param message [String The message, or a list of strings]
-- @param color=Color(255, 255, 255) [Color Color of the message text]
-- @see cw.core:Error
function cw.core:Print(message, color)
  color = color or Color(255, 255, 255)

  if type(message) == 'table' then
    message = table.concat(message, ' ')
  end

  if type(message) != 'string' then
    return
  elseif !message or message == '' or message == ' ' then
    return
  end

  MsgC(Color(100, 255, 100), '[Catwork] ')
  MsgC(color, message..'\n')
end

--- Prints a red error message when `cw.LogLevel` is 1 or higher.
-- @param message [String The message]
function cw.core:Error(message)
  if cw.LogLevel >= 1 then
    self:Print(message, Color(255, 0, 0))
  end
end

--- Prints a yellow warning message when `cw.LogLevel` is 2 or higher.
-- @param message [String The message]
function cw.core:Warning(message)
  if cw.LogLevel >= 2 then
    self:Print(message, Color(255, 255, 0))
  end
end

--- Prints a green success message when `cw.LogLevel` is 3 or higher.
-- @param message [String The message]
function cw.core:Good(message)
  if cw.LogLevel >= 3 then
    self:Print(message, Color(0, 255, 0))
  end
end

--- Prints a pink debug message when `cw.LogLevel` is 4 or higher.
-- @param message [String The message]
function cw.core:Debug(message)
  if cw.LogLevel >= 4 then
    self:Print(message, Color(255, 0, 255))
  end
end

--- Prints a pink verbose message when `cw.LogLevel` is 5 or higher.
-- @param message [String The message]
function cw.core:Spam(message)
  if cw.LogLevel >= 5 then
    self:Print(message, Color(255, 0, 255))
  end
end

--- Returns whether two tables have the same contents.
--
-- Compares the array length and then every key of `tableA` against `tableB`, recursing into
-- nested tables. Returns `false` when either argument is not a table.
-- @param tableA [Map The first table]
-- @param tableB [Map The second table]
-- @return [Boolean Whether the tables are equal]
function cw.core:AreTablesEqual(tableA, tableB)
  if istable(tableA) and istable(tableB) then
    if #tableA != #tableB then
      return false
    end

    for k, v in pairs(tableA) do
      if istable(v) and !self:AreTablesEqual(v, tableB[k]) then
        return false
      end

      if v != tableB[k] then
        return false
      end
    end

    return true
  end

  return false
end

--- Returns whether a weapon is a sandbox tool (physgun, gravity gun or toolgun).
-- @param weapon [Weapon The weapon to check]
-- @return [Boolean Whether the weapon is a default weapon; `false` for invalid entities]
function cw.core:IsDefaultWeapon(weapon)
  if IsValid(weapon) then
    local class = string.lower(weapon:GetClass())

    if class == 'weapon_physgun' or class == 'gmod_physcannon'
    or class == 'gmod_tool' then
      return true
    end
  end

  return false
end

--- Formats an amount of money with the schema's cash name.
--
-- Uses the `format_cash` or `format_singular_cash` option, replacing `%n` with the
-- `name_cash` option and `%a` with the rounded amount. On the client the cash name is translated.
-- @param amount [Number The amount of cash]
-- @param singular=false [Boolean Use the singular format]
-- @param lowerName=false [Boolean Lowercase the cash name; client only]
-- @return [String The formatted amount]
function cw.core:FormatCash(amount, singular, lowerName)
  local formatSingular = cw.option:GetKey('format_singular_cash')
  local formatCash = cw.option:GetKey('format_cash')
  local cashName = cw.option:GetKey('name_cash')

  if CLIENT then
    cashName = cw.lang:TranslateText(cashName)

    if lowerName then
      cashName = cashName:utf8lower()
    end
  end

  local realAmount = tostring(math.Round(amount))

  if singular then
    return self:Replace(self:Replace(formatSingular, '%n', cashName), '%a', realAmount)
  else
    return self:Replace(self:Replace(formatCash, '%n', cashName), '%a', realAmount)
  end
end

--- Merges one table into another without copying or following their `__index` fields.
--
-- Both tables keep their own `__index`.
-- @param to [Map The table to merge into]
-- @param from [Map The table to copy from]
function table.SafeMerge(to, from)
  local oldIndex, oldIndex2 = to.__index, from.__index

  to.__index = nil
  from.__index = nil

  table.Merge(to, from)

  to.__index = oldIndex
  from.__index = oldIndex2
end

--- Creates a library table, or returns it if it already exists.
--
-- ```
-- library.New('door', cw) -- creates cw.door
-- ```
--
-- @param strName [String Name of the library]
-- @param tParent=_G [Map Table the library is stored in]
-- @return [Map The library table]
-- @see library.Get
function library.New(strName, tParent)
  tParent = tParent or _G

  tParent[strName] = tParent[strName] or {}

  return tParent[strName]
end

--- Returns a library table, creating it if it does not exist.
--
-- `library` itself can be called as a shortcut: `library('door', cw)`.
-- @param strName [String Name of the library]
-- @param tParent=_G [Map Table the library is stored in]
-- @return [Map The library table]
-- @see library.New
function library.Get(strName, tParent)
  tParent = tParent or _G

  return tParent[strName] or library.New(strName, tParent)
end

-- Set library table's Metatable so that we can call it like a function.
setmetatable(library, { __call = function(tab, strName, tParent) return tab.Get(strName, tParent) end })

--- Creates a class table that can be called to create instances.
--
-- Calling the class creates a new object with the class as its metatable and a copy of its
-- fields, runs the base class (if any) and then the constructor, which is the method named after
-- the class. Constructor errors are printed instead of raised. The class gets `ClassName` and
-- `BaseClass` fields.
--
-- ```
-- library.NewClass('CItem', _G)
--
-- function CItem:CItem(name)
--   self.name = name
-- end
--
-- local item = CItem('Crowbar')
-- ```
--
-- @param strName [String Name of the class and of its constructor method]
-- @param tParent=_G [Map Table the class is stored in]
-- @param CExtends=nil [Map Base class whose fields are copied into the class metatable]
-- @return [Map The class table]
-- @see Class
function library.NewClass(strName, tParent, CExtends)
  local class = {
    -- Same as "new ClassName" in C++
    __call = function(obj, ...)
      local newObj = {}

      -- Set new object's meta table and copy the data from original class to new object.
      setmetatable(newObj, obj)
      table.SafeMerge(newObj, obj)

      -- If there is a base class, call their constructor.
      if obj.BaseClass then
        pcall(obj.BaseClass, newObj, ...)
      end

      -- If there is a constructor - call it.
      if obj[strName] then
        local success, value = pcall(obj[strName], newObj, ...)

        if !success then
          ErrorNoHalt('['..strName..'] Class constructor has failed to run!\n')
          ErrorNoHalt(value..'\n')
        end
      end

      -- Return our newly generated object.
      return newObj
    end
  }

  -- If this class is based off some other class - copy it's parent's data.
  if istable(CExtends) then
    table.SafeMerge(class, CExtends)
  end

  -- Create the actual class table.
  local obj = library.New(strName, (tParent or _G))
  obj.ClassName = strName
  obj.BaseClass = CExtends or false

  return setmetatable((tParent or _G)[strName], class)
end

--- Creates a global class; the short form of `library.NewClass`.
--
-- ```
-- class 'CItem'
-- ```
--
-- @param strName [String Name of the class]
-- @param CExtends=nil [Map Base class to inherit from]
-- @param tParent=_G [Map Table the class is stored in]
-- @return [Map The class table]
-- @alias [class]
-- @alias [Meta]
function Class(strName, CExtends, tParent)
  return library.NewClass(strName, tParent, CExtends)
end

-- Alias because class could get easily confused with player class.
Meta = Class

-- Also make an alias that looks like other programming languages.
class = Class

--- Parses a color from a comma-separated string.
--
-- Missing or invalid components default to 255.
-- @param text [String Components as `'r, g, b[, a]'`]
-- @return [Color The color]
function cw.core:StringToColor(text)
  local explodedData = string.Explode(',', text)
  local color = Color(255, 255, 255, 255)

  if explodedData[1] then
    color.r = tonumber(explodedData[1]:Trim()) or 255
  end

  if explodedData[2] then
    color.g = tonumber(explodedData[2]:Trim()) or 255
  end

  if explodedData[3] then
    color.b = tonumber(explodedData[3]:Trim()) or 255
  end

  if explodedData[4] then
    color.a = tonumber(explodedData[4]:Trim()) or 255
  end

  return color
end

--- Returns the color used for a log type.
-- @param logType [Number Log type 1 to 5; anything else uses the color of type 5]
-- @return [Color The color]
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

--- Returns the kernel version.
-- @return [String The value of `cw.KernelVersion`]
function cw.core:GetVersion()
  return cw.KernelVersion
end

--- Returns the kernel version and build.
--
-- Currently the same as `cw.core:GetVersion`.
-- @return [String The value of `cw.KernelVersion`]
function cw.core:GetVersionBuild()
  return cw.KernelVersion
end

--- Returns the schema folder, or a subfolder of its `schema` directory.
-- @param sFolderName=nil [String Subfolder inside `<schema>/schema/`]
-- @return [String The folder name or path]
function cw.core:GetSchemaFolder(sFolderName)
  if sFolderName then
    return cw.Schema..'/schema/'..sFolderNane
  else
    return cw.Schema
  end
end

--- Returns the schema gamemode folder name.
-- @return [String The value of `cw.Schema`]
function cw.core:GetSchemaGamemodePath()
  return cw.Schema
end

--- Returns the framework gamemode folder without the `gamemodes/` prefix.
-- @return [String The folder name, such as `'catwork'`]
function cw.core:GetClockworkFolder()
  return (string.gsub(cw.ClockworkFolder, 'gamemodes/', ''))
end

--- Returns the Lua path of the framework's `gamemode/core` directory.
-- @return [String The path, such as `'catwork/gamemode/core'`]
function cw.core:GetClockworkPath()
  return (string.gsub(cw.ClockworkFolder, 'gamemodes/', '')..'/gamemode/core')
end

--- Returns the absolute path of the game's root directory.
-- @return [String The full path without a trailing separator]
function cw.core:GetPathToGMod()
  return util.RelativePathToFull('.'):sub(1, -2)
end

--- Converts a string to a boolean.
-- @param text [String The text to convert]
-- @return [Boolean `true` for `'true'`, `'yes'` or `'1'`, otherwise `false`]
function cw.core:ToBool(text)
  if text == 'true' or text == 'yes' or text == '1' then
    return true
  else
    return false
  end
end

--- Removes a suffix from a string if it is present.
-- @param text [String The string to trim]
-- @param toRemove [String The suffix to remove]
-- @return [String The string without the suffix, or unchanged]
function cw.core:RemoveTextFromEnd(text, toRemove)
  local toRemoveLen = string.utf8len(toRemove)

  if string.utf8sub(text, -toRemoveLen) == toRemove then
    return (string.utf8sub(text, 0, -(toRemoveLen + 1)))
  else
    return text
  end
end

--- Splits a string into chunks of equal length.
-- @param text [String The string to split; UTF-8 aware]
-- @param interval [Number Characters per chunk]
-- @return [List<String> The chunks; the last one may be shorter]
function cw.core:SplitString(text, interval)
  local length = string.utf8len(text)
  local baseTable = {}
  local i = 0

  while i * interval < length do
    baseTable[i + 1] = string.utf8sub(text, i * interval + 1, (i + 1) * interval)
    i = i + 1
  end

  return baseTable
end

--- Returns whether a letter is an English vowel.
-- @param letter [String A single letter, case-insensitive]
-- @return [Boolean Whether it is a, e, i, o or u]
function cw.core:IsVowel(letter)
  letter = string.lower(letter)
  return (letter == 'a' or letter == 'e' or letter == 'i'
  or letter == 'o' or letter == 'u')
end

--- Returns the plural of some text.
--
-- Currently returns the text unchanged.
-- @param text [String The text]
-- @return [String The text]
function cw.core:Pluralize(text)
  return text
end

--- Serializes a table to a string.
--
-- Uses pON unless `bForceJSON` is set or pON fails, then falls back to JSON. Prints an error
-- and returns an empty string when the table cannot be serialized or is not a table.
-- @param tTable [Map The table to serialize]
-- @param bForceJSON=false [Boolean Always use JSON]
-- @return [String The serialized data]
-- @see cw.core:Deserialize
function cw.core:Serialize(tTable, bForceJSON)
  if istable(tTable) then
    local bSuccess, value

    if !bForceJSON then
      bSuccess, value = pcall(pon.encode, tTable)
    end

    if !bSuccess or bForceJSON then
      bSuccess, value = pcall(util.TableToJSON, tTable)

      if !bSuccess then
        ErrorNoHalt('[Catwork] Failed to serialize a table!\n')
        ErrorNoHalt(value..'\n')
        debug.Trace()

        return ''
      end
    end

    return value
  else
    print('[Catwork] You must serialize a table, not '..type(tTable)..'!')

    return ''
  end
end

--- Deserializes a string created by `cw.core:Serialize`.
--
-- Tries pON unless `bForceJSON` is set, then falls back to JSON. Prints an error and returns an
-- empty table when the data cannot be decoded or is not a string.
-- @param strData [String The serialized data]
-- @param bForceJSON=false [Boolean Always use JSON]
-- @return [Map The decoded table]
-- @see cw.core:Serialize
function cw.core:Deserialize(strData, bForceJSON)
  if isstring(strData) then
    local bSuccess, value

    if !bForceJSON then
      bSuccess, value = pcall(pon.decode, strData)
    end

    if !bSuccess or bForceJSON then
      bSuccess, value = pcall(util.JSONToTable, strData)

      if !bSuccess then
        ErrorNoHalt('[Catwork] Failed to deserialize a string!\n')
        ErrorNoHalt(tostring(value)..'\n')
        debug.Trace()

        return {}
      end
    end

    return value
  else
    print('[Catwork] You must deserialize a string, not '..type(strData)..'!')

    return {}
  end
end

--- Returns ammo information for a scripted weapon.
--
-- The table is cached on the weapon as `weapon.AmmoInfo` and refreshed on every call. It has
-- `primary` and `secondary` subtables with `ammoType`, `clipSize`, `ownerAmmo`, `clipBullets`,
-- `doesNotShoot` and `ownerClips`. Returns `nil` for invalid or ownerless weapons and weapons
-- without `Primary` and `Secondary` tables.
-- @param weapon [Weapon The weapon]
-- @return [Map The ammo information]
function cw.core:GetAmmoInformation(weapon)
  if IsValid(weapon) and IsValid(weapon.Owner) and weapon.Primary and weapon.Secondary then
    if !weapon.AmmoInfo then
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

    if !weapon.AmmoInfo.primary.doesNotShoot and weapon.AmmoInfo.primary.ownerAmmo > 0 then
      weapon.AmmoInfo.primary.ownerClips =
        math.ceil(weapon.AmmoInfo.primary.clipSize / weapon.AmmoInfo.primary.ownerAmmo)
    else
      weapon.AmmoInfo.primary.ownerClips = 0
    end

    if !weapon.AmmoInfo.secondary.doesNotShoot and weapon.AmmoInfo.secondary.ownerAmmo > 0 then
      weapon.AmmoInfo.secondary.ownerClips =
        math.ceil(weapon.AmmoInfo.secondary.clipSize / weapon.AmmoInfo.secondary.ownerAmmo)
    else
      weapon.AmmoInfo.secondary.ownerClips = 0
    end

    return weapon.AmmoInfo
  end
end

--- Runs a callback once an entity index becomes valid.
--
-- Calls it straight away when the entity already exists, otherwise polls with a timer.
--
-- ```
-- util.WaitForEntity(index, function(entity)
--   print(entity:GetModel())
-- end)
-- ```
--
-- @param entIndex [Number Entity index to wait for]
-- @param callback [Function Called with the entity]
-- @param delay=0 [Number Seconds between checks]
-- @param waitTime=100 [Number Maximum number of checks]
function util.WaitForEntity(entIndex, callback, delay, waitTime)
  local entity = Entity(entIndex)

  if !IsValid(entity) then
    local timerName = CurTime()..'_EntWait'

    timer.Create(timerName, delay or 0, waitTime or 100, function()
      local entity = Entity(entIndex)

      if IsValid(entity) then
        callback(entity)

        timer.Remove(timerName)
      end
    end)
  else
    callback(entity)
  end
end

-- Awful code because I'm out of time and Catwork is obsolete.
if CLIENT then
  netstream.Hook('PlayerModelChanged', function(nPlyIndex, sNewModel, sOldModel)
    util.WaitForEntity(nPlyIndex, function(player)
      hook.Run('PlayerModelChanged', player, sNewModel, sOldModel)
    end)
  end)
end

--- Loads the active schema and its plugins.
--
-- Creates `Schema`, merges the schema's gamemode info into it (sent to clients through
-- `CW_SCRIPT_SHARED.schemaData`), includes `sh_schema.lua` and the schema's extra folders,
-- caches its hooks and then includes the schema's plugins. Prints timings with
-- `cw.core:Debug`.
-- @warning [Internal] Called by the kernel while the gamemode loads.
function cw.core:LoadSchema()
  cw.core.schemaStartTime = cw.startTime or os.clock()
  local startTime = cw.core.schemaStartTime

  self:Debug('Schema loading benchmark: Schema loading started...')

  Schema = Schema or plugin.New()

  local directory = cw.Schema..'/schema'

  if SERVER then
    local schemaInfo = self:GetSchemaGamemodeInfo()
      table.Merge(Schema, schemaInfo)
    CW_SCRIPT_SHARED.schemaData = schemaInfo
  elseif CW_SCRIPT_SHARED.schemaData then
    table.Merge(Schema, CW_SCRIPT_SHARED.schemaData)
  else
    MsgC(Color(255, 100, 0, 255), '\n[Catwork] The schema has no '..schemaFolder..'.ini!\n')
  end

  self:Debug('Generated schema info table at '..math.Round(os.clock() - startTime, 3)..'.')

  self:Debug(directory..'/sh_schema.lua')

  if _file.Exists(directory..'/sh_schema.lua', 'LUA') then
    AddCSLuaFile(directory..'/sh_schema.lua')
    include(directory..'/sh_schema.lua')
  else
    MsgC(Color(255, 100, 0, 255), '\n[Catwork] The schema has no sh_schema.lua.\n')
  end

  self:Debug('Loaded sh_schema and rest of the files at '..math.Round(os.clock() - startTime, 3)..'.')

  plugin.IncludeExtras(directory)

  self:Debug('Included extras at '..math.Round(os.clock() - startTime, 3)..'.')

  plugin.CacheFunctions(Schema)

  self:Debug('Cached schema hooks at '..math.Round(os.clock() - startTime, 3)..'.')

  cw.core.schemaStartTime = nil

  directory = self:RemoveTextFromEnd(directory, '/schema')
  plugin.IncludePlugins(directory)

  self:Debug('Finished loading at '..math.Round(os.clock() - startTime, 3)..'.')
end

--- Splits a string by a separator, keeping text between open and close tags together.
--
-- ```
-- cw.core:ExplodeByTags('say "hello there"', ' ', '"', '"', true) -- { 'say', 'hello there' }
-- ```
--
-- @param text [String The text to split]
-- @param seperator [String Single character to split on]
-- @param open [String Single character that opens a tag]
-- @param close [String Single character that closes a tag]
-- @param hide=false [Boolean Remove the tag characters from the results]
-- @return [List<String> The parts]
function cw.core:ExplodeByTags(text, seperator, open, close, hide)
  local results = {}
  local current = ''
  local tag = nil

  for i = 1, #text do
    local character = string.utf8sub(text, i, i)

    if !tag then
      if character == open then
        if !hide then
          current = current..character
        end

        tag = true
      elseif character == seperator then
        results[#results + 1] = current current = ''
      else
        current = current..character
      end
    else
      if character == close then
        if !hide then
          current = current..character
        end

        tag = nil
      else
        current = current..character
      end
    end
  end

  if current != '' then
    results[#results + 1] = current
  end

  return results
end

--- Clamps and punctuates a physical description.
--
-- Descriptions with Cyrillic letters are cut to 256 characters, others to 1024, ending in
-- `...`. A period is added when the description does not end with punctuation.
-- @param description [String The description]
-- @return [String The modified description]
function cw.core:ModifyPhysDesc(description)
  -- Clamp russian physDesc length to 256.
  if string.find(description, '[абвгдеёжзийклмнопрстуфхцчшщъьыэюяАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЬЫЭЮЯ]') != nil then
    if string.utf8len(description) > 256 then
      return string.utf8sub(description, 1, 253)..'...'
    end
  end

  if string.utf8len(description) <= 1024 then
    if !string.find(string.utf8sub(description, -2), '%p') then
      return description..'.'
    else
      return description
    end
  else
    return string.utf8sub(description, 1, 1021)..'...'
  end
end

do
  local MAGIC_CHARACTERS = '([%(%)%.%%%+%-%*%?%[%^%$])'

  --- Replaces every occurrence of a plain string, without pattern matching.
  -- @param text [String The text to search]
  -- @param find [String The literal text to find]
  -- @param replace [String The replacement; `%` is still special here]
  -- @return [String The new text]
  function cw.core:Replace(text, find, replace)
    return (text:gsub(find:gsub(MAGIC_CHARACTERS, '%%%1'), replace))
  end
end

--- Creates an object that inherits from a table.
--
-- Sets `baseTable.__index` to itself and returns an empty table with it as the metatable.
-- @param baseTable [Map The table to inherit from]
-- @return [Map The new object]
function cw.core:NewMetaTable(baseTable)
  local object = {}
    setmetatable(object, baseTable)
    baseTable.__index = baseTable
  return object
end

--- Turns a table into a proxy table that stores non-function values in a subtable.
--
-- Existing non-function fields are moved into `baseTable[proxy]`, and `__index`/`__newindex`
-- are set so that reads and writes of non-function keys go there. If the object has a
-- `__proxy` method, reads of missing keys call it instead.
-- @param baseTable [Map The table to convert]
-- @param baseClass [Map Metatable to set on `baseTable`]
-- @param proxy [String Key of the subtable that holds the values]
function cw.core:MakeProxyTable(baseTable, baseClass, proxy)
  baseTable[proxy] = {}

  baseTable.__index = function(object, key)
    local value = rawget(object, key)

    if type(value) == 'function' then
      return value
    elseif object.__proxy then
      return object:__proxy(key)
    else
      return object[proxy][key]
    end
  end

  baseTable.__newindex = function(object, key, value)
    if type(value) != 'function' then
      object[proxy][key] = value
      return
    end

    rawset(object, key, value)
  end

  for k, v in pairs(baseTable) do
    if type(v) != 'function' and k != proxy then
      baseTable[proxy][k] = v
      baseTable[k] = nil
    end
  end

  setmetatable(baseTable, baseClass)
end

--- Changes the case of the first character of a string.
-- @param text [String The text]
-- @param bCamelCase [Boolean `true` to lowercase the first character, `false` to uppercase it]
-- @return [String The new text, Number The number of replacements made]
function cw.core:SetCamelCase(text, bCamelCase)
  if bCamelCase then
    return string.gsub(text, '^.', string.lower)
  else
    return string.gsub(text, '^.', string.upper)
  end
end

--- Adds the files in a directory to the client content download.
--
-- A path ending in `/` adds every file in it; otherwise the path is used as a search pattern.
-- @param directory [String Path relative to the game folder, such as `'materials/catwork/'`]
-- @param bRecursive=false [Boolean Also add subdirectories]
-- @see cw.core:AddFile
function cw.core:AddDirectory(directory, bRecursive)
  if string.utf8sub(directory, -1) == '/' then
    directory = directory..'*.*'
  end

  local files, folders = _file.Find(directory, 'GAME', 'namedesc')
  local rawDirectory = string.match(directory, '(.*)/')..'/'

  for k, v in ipairs(files) do
    self:AddFile(rawDirectory..v)
  end

  if bRecursive then
    for k, v in ipairs(folders) do
      if v != '..' and v != '.' then
        self:AddDirectory(rawDirectory..v, true)
      end
    end
  end
end

--- Adds a file to the client content download with `resource.AddFile`.
-- @param fileName [String Path relative to the game folder]
function cw.core:AddFile(fileName)
  resource.AddFile(fileName)
end

--- Includes a Lua file in the realm its prefix says.
--
-- On the server, `cl_` files are sent to clients, `sv_` and `init.lua` files are included and
-- anything else is both sent and included. On the client every file except `sv_` and
-- `init.lua` files is included.
-- @param strFile [String Path of the file]
-- @return [Any What the file returns, when it is included]
function util.Include(strFile)
  if SERVER then
    if string.find(strFile, 'cl_') then
      AddCSLuaFile(strFile)
    elseif string.find(strFile, 'sv_') or string.find(strFile, 'init.lua') then
      return include(strFile)
    else
      AddCSLuaFile(strFile)

      return include(strFile)
    end
  else
    if !string.find(strFile, 'sv_') and strFile != 'init.lua' and !strFile:EndsWith('/init.lua') then
      return include(strFile)
    end
  end
end

--- Sends a Lua file to clients when its name marks it as client or shared.
--
-- Matches `sh_`, `cl_` and `shared.lua`. Does nothing on the client.
-- @param strFile [String Path of the file]
function util.AddCSLuaFile(strFile)
  if SERVER then
    if string.find(strFile, 'sh_') or string.find(strFile, 'cl_') or string.find(strFile, 'shared.lua') then
      AddCSLuaFile(strFile)
    end
  end
end

--- Includes every Lua file in a directory with `util.Include`.
--
-- ```
-- util.IncludeDirectory('libraries', true) -- catwork/gamemode/core/libraries/
-- ```
--
-- @param strDirectory [String The directory]
-- @param strBase=nil [String Prefix for `strDirectory`; `true` uses `'catwork/gamemode/core/'`]
-- @param bIsRecursive=false [Boolean Also include subdirectories, files first]
function util.IncludeDirectory(strDirectory, strBase, bIsRecursive)
  if strBase then
    if isbool(strBase) then
      strBase = 'catwork/gamemode/core/'
    elseif !strBase:EndsWith('/') then
      strBase = strBase..'/'
    end

    strDirectory = strBase..strDirectory
  end

  if !strDirectory:EndsWith('/') then
    strDirectory = strDirectory..'/'
  end

  if bIsRecursive then
    local files, folders = _file.Find(strDirectory..'*', 'LUA', 'namedesc')

    -- First include the files.
    for k, v in ipairs(files) do
      if v:GetExtensionFromFilename() == 'lua' then
        util.Include(strDirectory..v)
      end
    end

    -- Then include all directories.
    for k, v in ipairs(folders) do
      util.IncludeDirectory(strDirectory..v, bIsRecursive)
    end
  else
    local files, _ = _file.Find(strDirectory..'*.lua', 'LUA', 'namedesc')

    for k, v in ipairs(files) do
      util.Include(strDirectory..v)
    end
  end
end

--- Includes every Lua file in a directory; see `util.IncludeDirectory`.
-- @param directory [String The directory]
-- @param bFromBase=nil [String Prefix for the directory; `true` uses `'catwork/gamemode/core/'`]
function cw.core:IncludeDirectory(directory, bFromBase)
  return util.IncludeDirectory(directory, bFromBase)
end

--- Includes a file in the realm its prefix says; see `util.Include`.
-- @param fileName [String Path of the file]
-- @return [Any What the file returns, when it is included]
function cw.core:IncludePrefixed(fileName)
  return util.Include(fileName)
end

--- Includes every plugin in a directory.
--
-- Single-file plugins (`*.lua`) and plugin folders (`<name>/plugin`) are loaded with
-- `plugin.Include`.
-- @param directory [String The plugins directory]
-- @param bFromBase=false [Boolean Prefix the directory with `'catwork/'`]
-- @return [Boolean Always `true`]
function cw.core:IncludePlugins(directory, bFromBase)
  if bFromBase then
    directory = 'catwork/'..directory
  end

  if string.sub(directory, -1) != '/' then
    directory = directory..'/'
  end

  local files, pluginFolders = _file.Find(directory..'*', 'LUA', 'namedesc')

  for k, v in ipairs(files) do
    if v:EndsWith('.lua') then
      plugin.Include(directory..v)
    end
  end

  for k, v in ipairs(pluginFolders) do
    if v != '..' and v != '.' then
      plugin.Include(directory..v..'/plugin')
    end
  end

  return true
end

--- Runs a function on the next frame.
-- @param name [String Unique timer name; reusing it replaces the pending call]
-- @param Callback [Function The function to run]
function cw.core:OnNextFrame(name, Callback)
  return timer.Create(name, FrameTime(), 1, Callback)
end

--- Returns whether a player may use an object such as an item, class or attribute.
--
-- Access is granted when the player has any of the object's `access` flags, belongs to one of
-- its `factions` or `classes` (by team index or class name), or when none of those fields are
-- set. A matching faction, class or flag in `blacklist` denies access. An
-- `object:HasObjectAccess(player, hasAccess)` method, if present, has the final say.
-- @param player [Player The player]
-- @param object [Map Table with optional `access`, `factions`, `classes` and `blacklist` fields]
-- @return [Boolean Whether the player has access]
function cw.core:HasObjectAccess(player, object)
  local hasAccess = false

  if object.access then
    if cw.player:HasAnyFlags(player, object.access) then
      hasAccess = true
    end
  end

  if object.factions then
    local faction = player:GetFaction()

    if table.HasValue(object.factions, faction) then
      hasAccess = true
    end
  end

  if object.classes then
    local team = player:Team()
    local class = cw.class:FindByID(team)

    if class then
      if table.HasValue(object.classes, team)
      or table.HasValue(object.classes, class.name) then
        hasAccess = true
      end
    end
  end

  if !object.access and !object.factions
  and !object.classes then
    hasAccess = true
  end

  if object.blacklist then
    local team = player:Team()
    local class = cw.class:FindByID(team)
    local faction = player:GetFaction()

    if table.HasValue(object.blacklist, faction) then
      hasAccess = false
    elseif class then
      if table.HasValue(object.blacklist, team)
      or table.HasValue(object.blacklist, class.name) then
        hasAccess = false
      end
    else
      for k, v in pairs(object.blacklist) do
        if type(v) == 'string' then
          if cw.player:HasAnyFlags(player, v) then
            hasAccess = false

            break
          end
        end
      end
    end
  end

  if object.HasObjectAccess then
    return object:HasObjectAccess(player, hasAccess)
  end

  return hasAccess
end

--- Returns the names of all registered commands in alphabetical order.
-- @return [List<String> The command names]
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

--- Pads a number with leading zeros.
-- @param number [Number The number]
-- @param digits [Number Minimum length of the result]
-- @return [String The padded number]
function cw.core:ZeroNumberToDigits(number, digits)
  return string.rep('0', math.Clamp(digits - string.utf8len(tostring(number)), 0, digits))..tostring(number)
end

--- Returns a short checksum of a string.
-- @param value [String The value to hash]
-- @return [Number The CRC divided by 100000, rounded up]
function cw.core:GetShortCRC(value)
  return math.ceil(util.CRC(value) / 100000)
end

--- Removes falsy entries from the array part of a table, in place.
-- @param baseTable [List The table to clean]
function cw.core:ValidateTableKeys(baseTable)
  for i = 1, #baseTable do
    if !baseTable[i] then
      table.remove(baseTable, i)
    end
  end
end

--- Returns every `prop_physics` and `prop_physics_multiplayer` entity.
-- @return [List<Entity> The entities]
function cw.core:GetPhysicsEntities()
  local entities = {}

  for k, v in ipairs(ents.FindByClass('prop_physics_multiplayer')) do
    if IsValid(v) then
      table.insert(entities, v)
    end
  end

  for k, v in ipairs(ents.FindByClass('prop_physics')) do
    if IsValid(v) then
      table.insert(entities, v)
    end
  end

  return entities
end

--- Makes a table forward method calls to each of its values.
--
-- Calling `baseTable:Method(...)` calls `object.Method(value, ...)` for every value in the table.
--
-- ```
-- local players = cw.core:CreateMulticallTable(player.GetAll(), FindMetaTable('Player'))
-- players:Freeze(true)
-- ```
--
-- @param baseTable [List The values to call methods on]
-- @param object [Map Table the methods are looked up in]
-- @return [List The same table, with its metatable set]
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

--- Creates a damage info object.
-- @param damage [Number Damage amount; rounded up and clamped to 0 or more]
-- @param inflictor [Entity The inflictor]
-- @param attacker [Entity The attacker]
-- @param position [Vector Damage position]
-- @param damageType [Number A `DMG_*` damage type]
-- @param damageForce [Number Scale of the damage force]
-- @return [CTakeDamageInfo The damage info]
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

--- Returns the components of a color.
-- @param color [Color The color]
-- @return [Number Red, Number Green, Number Blue, Number Alpha]
function cw.core:UnpackColor(color)
  return color.r, color.g, color.b, color.a
end

--- Expands the placeholders in a text.
--
-- `^amount^` becomes formatted cash and `!amount!` singular cash (with `(amount)` for a
-- lowercase cash name), `*key*` the value of an option (`*(key)*` passes `true` to
-- `cw.option:GetKey`) and, on the client, `:command:` the key bound to a command. Finally
-- `config.Parse` replaces `$key$` with config values.
--
-- ```
-- cw.core:ParseData('It costs ^50^. Press :+use: to buy.')
-- ```
--
-- @param text [String The text to parse]
-- @return [String The parsed text]
function cw.core:ParseData(text)
  local classes = { '%^', '%!' }

  for k, v in ipairs(classes) do
    for key in string.gmatch(text, v..'(.-)'..v) do
      local lower = false
      local amount

      if string.utf8sub(key, 1, 1) == '(' and string.utf8sub(key, -1) == ')' then
        lower = true
        amount = tonumber(string.utf8sub(key, 2, -2))
      else
        amount = tonumber(key)
      end

      if amount then
        text =
          string.gsub(
            text,
            v..string.gsub(key, '([%(%)])', '%%%1')..v,
            tostring(self:FormatCash(amount, k == 2, lower))
          )
      end
    end
  end

  for k in string.gmatch(text, '%*(.-)%*') do
    k = string.gsub(k, '[%(%)]', '')

    if k != '' then
      text = string.gsub(text, '%*%('..k..'%)%*', tostring(cw.option:GetKey(k, true)))
      text = string.gsub(text, '%*'..k..'%*', tostring(cw.option:GetKey(k)))
    end
  end

  if CLIENT then
    for k in string.gmatch(text, ':(.-):') do
      if k != '' and input.LookupBinding(k) then
        text = self:Replace(text, ':'..k..':', '<'..string.upper(tostring(input.LookupBinding(k)))..'>')
      end
    end
  end

  return config.Parse(text)
end

--- Sets a global networked variable; see `netvars.SetNetVar`.
--
-- Only works on the server.
-- @param key [String Name of the variable]
-- @param val [Any The new value]
-- @param sendTo=nil [Player Player or recipients to send it to; `nil` sends to everyone]
-- @see cw.core:GetSharedVar
function cw.core:SetSharedVar(key, val, sendTo)
  return netvars.SetNetVar(key, val, sendTo)
end

--- Returns a global networked variable; see `netvars.GetNetVar`.
-- @param key [String Name of the variable]
-- @param default=nil [Any Value returned when the variable is not set]
-- @return [Any The value]
-- @see cw.core:SetSharedVar
function cw.core:GetSharedVar(key, default)
  return netvars.GetNetVar(key, default)
end

timer.Create('cw.HalfSecondTimer', 0.5, 0, function()
  hook.Run('HalfSecond')
end)

timer.Create('cw.OneSecondTimer', 1, 0, function()
  hook.Run('OneSecond')
end)

timer.Create('cw.OneMinuteTimer', 60, 0, function()
  hook.Run('OneMinute')
end)

timer.Create('LazyTick', 0.125, 0, function()
  hook.Run('LazyTick')
end)
