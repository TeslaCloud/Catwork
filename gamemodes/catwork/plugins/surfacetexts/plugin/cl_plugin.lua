--- Client-side functions of the Surface Texts plugin that receive the text list from the server and find the text under
-- the crosshair for removal.
--
-- The `cwLoad3DTexts`, `cw3DText_Add` and `cw3DText_Remove` netstreams keep `cwSurfaceTexts.stored` in sync, and
-- `cwSurfaceTexts:RemoveAtTrace` asks the server to remove the text a trace runs through.
--
-- Backported from the [Flux](https://github.com/TeslaCloud/flux-ce) project.

netstream.Hook('cwLoad3DTexts', function(data)
  cwSurfaceTexts.stored = data or {}
end)

netstream.Hook('cw3DText_Add', function(idx, data)
  cwSurfaceTexts.stored[idx] = data
end)

netstream.Hook('cw3DText_Remove', function(idx)
  cwSurfaceTexts.stored[idx] = nil
end)

netstream.Hook('cw3DText_Calculate', function()
  cwSurfaceTexts:RemoveAtTrace(cw.client:GetEyeTraceNoCursor())
end)

--- Asks the server to remove the first surface text a trace runs through.
--
-- A text is hit when the trace crosses the line along its width and the hit position is within
-- `5 * scale` units of its height. The server removes it only if the player is an admin.
--
-- @param trace [Map A trace result, such as from `GetEyeTraceNoCursor`]
-- @return [Boolean Whether a text was hit and a removal request was sent]
function cwSurfaceTexts:RemoveAtTrace(trace)
  if !trace then return false end

  local hitPos = trace.HitPos
  local traceStart = trace.StartPos

  for k, v in pairs(self.stored) do
    local pos = v.pos
    local normal = v.normal
    local ang = normal:Angle()
    local w, h = util.GetTextSize(cw.option:GetFont('large_3d_2d'), v.text)

    local startPos = pos - -ang:Right() * (w / 22) * v.scale
    local endPos = pos + -ang:Right() * (w / 22) * v.scale

    if math.abs(math.abs(hitPos.z) - math.abs(pos.z)) < 5 * v.scale then
      if util.VectorsIntersect(traceStart, hitPos, startPos, endPos) then
        netstream.Start('cw3DText_Remove', k)

        return true
      end
    end
  end

  return false
end
