--- Client-side hooks of the Karma plugin that show karma in the interface.
--
-- They add the karma level to the local player's info text, draw a karma bar with a slider in the info menu, and show
-- the karma level under recognised non-Combine players the local player looks at.

--- Called when the local player's info text is built; adds the karma level line.
-- @param playerInfoText [Map The info text object; lines are added with `:Add(id, text)`]
function cwKarma:GetPlayerInfoText(playerInfoText)
  playerInfoText:Add('KARMA', L('#Karma')..': '..L(cw.client:GetKarmaLevel()))
end

local mat_karma = Material('materials/catwork/karma_bar.png')

--- Called while the info menu is painted; draws the karma bar with a slider at the local player's karma.
-- @param info [Map Drawing area with `x`, `y`, `width` and `height`; `info:Adjust(n)` moves it down by `n`]
function cwKarma:PaintInfoMenuExtras(info)
  local x, y, w, h = info.x, info.y, info.width, info.height
  local adjust = 0
  local karma = cw.client:GetKarma()
  local normal = karma / 100

  cw.core:DrawInfo('#Karma_InfoMenu', x, y, cw.option:GetColor('information'), nil, true, function(x, y, width, height)
    adjust = adjust + height + 4

    return x, y
  end)

  y = y + adjust

  draw.RoundedBox(4, x, y, w, 64, Color(0, 0, 0))

  local barWidth = w - 32

  draw.TexturedRect(x + 16, y + 18, barWidth, 28, mat_karma)

  local centerPos = x + 16 + (barWidth / 2 - 2)
  local sliderPos = centerPos + ((barWidth / 2) * normal)

  draw.RoundedBox(0, sliderPos, y + 14, 4, 36, Color(255, 255, 255))

  adjust = adjust + 70

  info:Adjust(adjust)
end

--- Called when a targeted player's status is drawn; shows the karma level of recognised non-Combine players.
-- @param entity [Entity The targeted entity]
-- @param alpha [Number Opacity of the target text]
-- @param x [Number Horizontal centre of the text]
-- @param y [Number Vertical position to draw at]
-- @return [Number The `y` position below the drawn text, or `nil` when nothing was drawn]
function cwKarma:DrawPlayerStatusExtra(entity, alpha, x, y)
  if entity:IsPlayer() and !entity:IsCombine() and cw.player:DoesRecognise(entity) then
    local font = cw.option:GetFont('target_id_text')
    local w, h = util.GetTextSize(font, entity:GetKarmaLevel())

    draw.SimpleText(entity:GetKarmaLevel(), font, x - w / 2, y, cw.option:GetColor('information'))

    return y + h
  end
end
