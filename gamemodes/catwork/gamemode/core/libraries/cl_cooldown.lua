--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

library.New('cooldown', cw)

cw.cooldown.sizes = cw.cooldown.sizes or {}

--- Returns the cached polygon table for a cooldown box size.
-- @param width [Number Width of the cooldown box]
-- @param height [Number Height of the cooldown box]
-- @param bAdd=nil [Boolean Whether to create the table with `cw.cooldown:AddSize` if it does not exist]
-- @return [Map The cooldown table with `verticies` and `editTable` keys, or `nil` if the size is
-- not cached and `bAdd` is not set]
function cw.cooldown:GetTable(width, height, bAdd)
  local cooldownTable = self.sizes[width..' '..height]

  if cooldownTable then
    return cooldownTable
  elseif bAdd then
    return self:AddSize(width, height)
  end
end

--- Builds and caches the polygon table for a cooldown box size.
--
-- The box is split into eight octants so it can be drawn partially filled.
-- Sizes 64x64 and 32x32 are added when the file loads.
-- @param width [Number Width of the cooldown box]
-- @param height [Number Height of the cooldown box]
-- @return [Map The new cooldown table with `verticies` and `editTable` keys]
function cw.cooldown:AddSize(width, height)
  local verticies = {
    {
      { x = 0, y = -(height / 2), u = 0.5, v = 0 },
      { x = width / 2, y = -(height / 2), u = 1, v = 0, c = function()
        return -(width / 2), 0
      end }
    },
    {
      { x = width / 2, y = -(height / 2), u = 1, v = 0 },
      { x = width / 2, y = 0, u = 1, v = 0.5, c = function()
        return 0, -(height / 2)
      end }
    },
    {
      { x = width / 2, y = 0, u = 1, v = 0.5 },
      { x = width / 2, y = height / 2, u = 1, v = 1, c = function()
        return 0, -(height / 2)
      end }
    },
    {
      { x = width / 2, y = height / 2, u = 1, v = 1 },
      { x = 0, y = height / 2, u = 0.5, v = 1, c = function()
        return width / 2, 0
      end }
    },
    {
      { x = 0, y = height / 2, u = 0.5, v = 1 },
      { x = -(width / 2), y = height / 2, u = 0, v = 1, c = function()
        return width / 2, 0
      end }
    },
    {
      { x = -(width / 2), y = height / 2, u = 0, v = 1 },
      { x = -(width / 2), y = 0, u = 0, v = 0.5, c = function()
        return 0, height / 2
      end }
    },
    {
      { x = -(width / 2), y = 0, u = 0, v = 0.5 },
      { x = -(width / 2), y = -(height / 2), u = 0, v = 0, c = function()
        return 0, height / 2
      end }
    },
    {
      { x = -(width / 2), y = -(height / 2), u = 0, v = 0 },
      { x = 0, y = -(height / 2), u = 0.5, v = 0, c = function()
        return -(width / 2), 0
      end }
    }
  }

  local editTable = table.Copy(verticies)

  self.sizes[width..' '..height] = {
    verticies = verticies,
    editTable = editTable
  }

  return self.sizes[width..' '..height]
end

--- Draws a cooldown box that fills clockwise as progress goes from 0 to 100.
--
-- Must be called from a 2D rendering hook. The size is cached on first use.
--
-- ```
-- cw.cooldown:DrawBox(x, y, 64, 64, percentage, Color(255, 255, 255, 100), surface.GetTextureID('vgui/white'))
-- ```
--
-- @param x [Number Horizontal position of the box]
-- @param y [Number Vertical position of the box]
-- @param width [Number Width of the cooldown box]
-- @param height [Number Height of the cooldown box]
-- @param progress [Number Progress of the cooldown, from 0 to 100]
-- @param color [Color Color of the box]
-- @param textureID [Number Texture ID to draw with, from `surface.GetTextureID`]
-- @param bCenter=nil [Boolean Whether `x` and `y` are the center of the box instead of its top left corner]
function cw.cooldown:DrawBox(x, y, width, height, progress, color, textureID, bCenter)
  local cooldownTable = self:GetTable(width, height, true)
  local octant = math.Clamp((8 / 100) * progress, 0, 8)

  if !bCenter then
    x = x + (width / 2)
    y = y + (height / 2)
  end

  surface.SetTexture(textureID)
  surface.SetDrawColor(color.r, color.g, color.b, color.a)

  local polygons = { { x = x, y = y, u = 0.5, v = 0.5 } }

  for i = 1, 8 do
    if math.ceil(octant) == i then
      local fraction = 1 - (i - octant)
      local nx, ny = cooldownTable.editTable[i][2].c()

      cooldownTable.editTable[i][2].x = x + cooldownTable.verticies[i][2].x + nx + (-nx * fraction)
      cooldownTable.editTable[i][2].y = y + cooldownTable.verticies[i][2].y + ny + (-ny * fraction)
      cooldownTable.editTable[i][1].x = x + cooldownTable.verticies[i][1].x
      cooldownTable.editTable[i][1].y = y + cooldownTable.verticies[i][1].y

      table.Add(polygons, cooldownTable.editTable[i])
    elseif octant > i then
      for j = 1, 2 do
        cooldownTable.editTable[i][j].x = x + cooldownTable.verticies[i][j].x
        cooldownTable.editTable[i][j].y = y + cooldownTable.verticies[i][j].y
      end

      table.Add(polygons, cooldownTable.editTable[i])
    end
  end

  surface.DrawPoly(polygons)
end

cw.cooldown:AddSize(64, 64)
cw.cooldown:AddSize(32, 32)
