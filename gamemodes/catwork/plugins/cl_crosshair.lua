--[[
  Flux © 2016-2017 TeslaCloud Studios
  Do not share or re-distribute before
  the framework is publicly released.
--]]

PLUGIN.name = 'Crosshair'
PLUGIN.author = 'Mr. Meow'
PLUGIN.description = 'Adds a crosshair.'

local curSize = nil
local size = 2
local halfSize = size / 2
local gap = 8
local curGap = gap

--- Called when the HUD is painted; draws a five-dot crosshair whose gap widens with the aimed distance.
--
-- Nothing is drawn when the `PreDrawCrosshair` hook returns true. The `AdjustCrosshairColor` and
-- `AdjustCrosshairGap` hooks, called with the eye trace and its distance, can override the color and
-- the gap; the gap eases towards its target each frame.
function PLUGIN:HUDPaint()
  if !plugin.Call('PreDrawCrosshair') then
    local trace = cw.client:GetEyeTraceNoCursor()
    local distance = cw.client:GetPos():Distance(trace.HitPos)
    local drawColor = plugin.Call('AdjustCrosshairColor', trace, distance) or Color(255, 255, 255)
    local realGap =
      plugin.Call('AdjustCrosshairGap', trace, distance) or math.Round(gap * math.Clamp(distance / 400, 0.5, 4))
    curGap = Lerp(FrameTime() * 6, curGap, realGap)

    if math.abs(curGap - realGap) < 0.5 then
      curGap = realGap
    end

    local scrW, scrH = ScrW(), ScrH()

    draw.RoundedBox(0, scrW / 2 - halfSize, scrH / 2 - halfSize, size, size, drawColor)

    draw.RoundedBox(0, scrW / 2 - halfSize - curGap, scrH / 2 - halfSize, size, size, drawColor)
    draw.RoundedBox(0, scrW / 2 - halfSize + curGap, scrH / 2 - halfSize, size, size, drawColor)

    draw.RoundedBox(0, scrW / 2 - halfSize, scrH / 2 - halfSize - curGap, size, size, drawColor)
    draw.RoundedBox(0, scrW / 2 - halfSize, scrH / 2 - halfSize + curGap, size, size, drawColor)
  end
end

--- Called to pick the crosshair color; uses the `information` color when aiming at a nearby player or item.
--
-- @param trace [Map The local player's eye trace]
-- @param distance [Number Distance from the player to the trace hit position]
-- @return [Color The crosshair color within 600 units of a player or `cw_item`, otherwise nil]
function PLUGIN:AdjustCrosshairColor(trace, distance)
  local ent = trace.Entity

  if distance < 600 and IsValid(ent) and (ent:IsPlayer() or ent:GetClass() == 'cw_item') then
    return cw.option:GetColor('information')
  end
end

--- Called to pick the crosshair gap; keeps it at 8 when aiming at a nearby player or item.
--
-- @param trace [Map The local player's eye trace]
-- @param distance [Number Distance from the player to the trace hit position]
-- @return [Number The gap in pixels within 600 units of a player or `cw_item`, otherwise nil]
function PLUGIN:AdjustCrosshairGap(trace, distance)
  local ent = trace.Entity

  if distance < 600 and IsValid(ent) and (ent:IsPlayer() or ent:GetClass() == 'cw_item') then
    return 8
  end
end

--- Called before the crosshair is drawn; hides it when the `enable_crosshair` config is false.
--
-- @return [Boolean True to skip drawing the crosshair, otherwise nil]
function PLUGIN:PreDrawCrosshair()
  if config.GetVal('enable_crosshair') == false then
    return true
  end
end
