--[[
  (C) 2016 TeslaCloud Studios
  For internal distribution only.
--]]

library.New('cdraw', _G)

cdraw.Blur = Material('pp/blurscreen')

if !_G['ClockworkClientsideBooted'] then
  -- Create all font sizes at once. I am just too tired of creating a new font for each size I wanna use.
  for i = 1, 72 do
    surface.CreateFont('Derma'..i, {
      font = 'Roboto',
      size = i,
      weight = 500,
      extended = true
    })

    surface.CreateFont('DermaNarrow'..i, {
      font = 'RobotoCondensed',
      size = i,
      weight = 400,
      extended = true
    })

    surface.CreateFont('DermaNarrowBold'..i, {
      font = 'RobotoCondensed',
      size = i,
      weight = 800,
      extended = true
    })

    surface.CreateFont('Exo'..i, {
      font = 'Exo 2',
      size = i,
      weight = 400,
      extended = true
    })

    surface.CreateFont('ExoBold'..i, {
      font = 'Exo 2',
      size = i,
      weight = 800,
      extended = true
    })

    surface.CreateFont('DermaBold'..i, {
      font = 'Roboto',
      size = i,
      weight = 1000,
      extended = true
    })

    surface.CreateFont('DermaThin'..i, {
      font = 'Roboto',
      size = i,
      weight = 150,
      extended = true
    })

    surface.CreateFont('DermaGlow'..i, {
      font = 'Roboto',
      size = i,
      blursize = 4,
      scanlines = 2,
      weight = 500,
      extended = true
    })
  end
end

--- Returns the size of a text when drawn with a font.
--
-- Sets the current `surface` font as a side effect.
-- @param font [String Name of the font]
-- @param text [String Text to measure]
-- @return [Number Width in pixels, Number Height in pixels]
function util.GetTextSize(font, text)
  surface.SetFont(font)

  return surface.GetTextSize(text)
end

--- Draws a rounded box.
-- @param x [Number Horizontal position]
-- @param y [Number Vertical position]
-- @param w [Number Width]
-- @param h [Number Height]
-- @param color=Color(200,200,200) [Color Fill color]
-- @param RoundAmt=4 [Number Corner radius]
function cdraw.DrawBox(x, y, w, h, color, RoundAmt)
  RoundAmt = RoundAmt or 4
  color = color or Color(200, 200, 200)
  draw.RoundedBox(RoundAmt, x, y, w, h, color)
end

--- Draws text with one of the sized fonts created by this library.
--
-- The font name is `font` followed by `size`, such as `Derma24` or `ExoBold16`;
-- sizes 1 to 72 exist for `Derma`, `DermaNarrow`, `DermaNarrowBold`, `Exo`,
-- `ExoBold`, `DermaBold`, `DermaThin` and `DermaGlow`.
-- @param text [String Text to draw]
-- @param x [Number Horizontal position]
-- @param y [Number Vertical position]
-- @param size [Number Font size, from 1 to 72]
-- @param color [Color Text color]
-- @param font='Derma' [String Font family prefix]
function cdraw.DrawText(text, x, y, size, color, font)
  font = font or 'Derma'
  surface.SetFont(font..size)
  surface.SetTextColor(color)
  surface.SetTextPos(x, y)
  surface.DrawText(text)
end

--- Draws a box that blurs what is behind it.
--
-- Must be called from a panel's `Paint`: the colored box is drawn at the panel's
-- origin and `x`, `y` are the panel's screen position, used to line up the blur.
-- @param x [Number Horizontal screen position of the panel]
-- @param y [Number Vertical screen position of the panel]
-- @param w [Number Width]
-- @param h [Number Height]
-- @param color [Color Color of the box drawn under the blur]
-- @param blurAmt=4 [Number Strength of the blur]
-- @see cdraw.DrawBlurBox
function cdraw.DrawSimpleBlurBox(x, y, w, h, color, blurAmt)
  blurAmt = blurAmt or 4

  cdraw.DrawBox(0, 0, w, h, color)

  surface.SetMaterial(cdraw.Blur)
  surface.SetDrawColor(255, 255, 255, 255)

  for i = -0.2, 1, 0.2 do
    cdraw.Blur:SetFloat('$blur', i * blurAmt)
    cdraw.Blur:Recompute()

    render.UpdateScreenEffectTexture()

    render.SetScissorRect(x, y, x + w, y + h, true)
      surface.DrawTexturedRect(-x, -y, ScrW(), ScrH())
    render.SetScissorRect(0, 0, 0, 0, false)
  end
end

--- Draws a box that blurs what is behind it, at a position inside a panel.
--
-- Must be called from a panel's `Paint`. The blur strength is always 4;
-- `blurAmt` is ignored.
-- @param px [Number Horizontal screen position of the panel]
-- @param py [Number Vertical screen position of the panel]
-- @param x [Number Horizontal position of the box inside the panel]
-- @param y [Number Vertical position of the box inside the panel]
-- @param w [Number Width]
-- @param h [Number Height]
-- @param color [Color Color of the box drawn under the blur]
-- @param blurAmt=nil [Number Unused]
-- @see cdraw.DrawSimpleBlurBox
function cdraw.DrawBlurBox(px, py, x, y, w, h, color, blurAmt)
  blurAmt = 4

  cdraw.DrawBox(x, y, w, h, color)

  surface.SetMaterial(cdraw.Blur)
  surface.SetDrawColor(255, 255, 255, 255)

  for i = -0.2, 1, 0.2 do
    cdraw.Blur:SetFloat('$blur', i * blurAmt)
    cdraw.Blur:Recompute()

    render.UpdateScreenEffectTexture()

    render.SetScissorRect(px, py, w, h, true)
      surface.DrawTexturedRect(-px, -py, ScrW(), ScrH())
    render.SetScissorRect(0, 0, 0, 0, false)
  end
end

--- Draws a box in the theme's `panel_primarycolor` option color.
-- @param name [Any Unused]
-- @param x [Number Horizontal position]
-- @param y [Number Vertical position]
-- @param w [Number Width]
-- @param h [Number Height]
function cdraw.DrawPanelBase(name, x, y, w, h)
  cdraw.DrawBox(x, y, w, h, cw.option:GetColor('panel_primarycolor'))
end

--- Draws a parallelogram whose bottom edge is shifted to the right.
-- @param x1 [Number Horizontal position of the top left corner]
-- @param y1 [Number Vertical position of the top left corner]
-- @param w [Number Width of the top edge]
-- @param h [Number Height]
-- @param pct [Number Horizontal offset of the bottom edge in pixels]
-- @param col [Color Fill color]
function cdraw.DrawEZPoly(x1, y1, w, h, pct, col)
  local poly = {
    { x = x1, y = y1 },
    { x = x1 + w, y = y1 },
    { x = x1 + w + pct, y = y1 + h },
    { x = x1 + pct, y = y1 + h }
  }

  surface.SetDrawColor(col)
  draw.NoTexture()
  surface.DrawPoly(poly)
end

--- Draws a box whose right edge slants outwards towards the bottom.
-- @param x1 [Number Horizontal position of the top left corner]
-- @param y1 [Number Vertical position of the top left corner]
-- @param w [Number Width of the top edge]
-- @param h [Number Height]
-- @param pct [Number How far the bottom right corner extends past the top right one, in pixels]
-- @param col [Color Fill color]
function cdraw.DrawEZHalfPoly(x1, y1, w, h, pct, col)
  local poly = {
    { x = x1, y = y1 },
    { x = x1 + w, y = y1 },
    { x = x1 + w + pct, y = y1 + h },
    { x = x1, y = y1 + h }
  }

  surface.SetDrawColor(col)
  draw.NoTexture()
  surface.DrawPoly(poly)
end

--- Draws a box whose left edge slants outwards towards the bottom.
-- @param x1 [Number Horizontal position of the top left corner]
-- @param y1 [Number Vertical position of the top left corner]
-- @param w [Number Width of the top edge]
-- @param h [Number Height]
-- @param pct [Number How far the bottom left corner extends past the top left one, in pixels]
-- @param col [Color Fill color]
function cdraw.DrawEZHalfPolyRight(x1, y1, w, h, pct, col)
  local poly = {
    { x = x1, y = y1 },
    { x = x1 + w, y = y1 },
    { x = x1 + w, y = y1 + h },
    { x = x1 - pct, y = y1 + h }
  }

  surface.SetDrawColor(col)
  draw.NoTexture()
  surface.DrawPoly(poly)
end

--- Draws a slanted progress bar with a dark background.
-- @param x [Number Horizontal position]
-- @param y [Number Vertical position]
-- @param w [Number Width]
-- @param h [Number Height]
-- @param pct [Number Progress, from 0 to 100]
-- @param col [Color Color of the filled part]
function cdraw.PolyBar(x, y, w, h, pct, col)
  cdraw.DrawEZHalfPoly(x, y, w, h, 32, Color(65, 65, 65, 190))

  if (pct / 100) != 0 then
    cdraw.DrawEZHalfPoly(x + 1, y + 1, (w - 2) * (pct / 100), h - 2, 32, col)
  end
end
