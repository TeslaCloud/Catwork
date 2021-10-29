--[[
	LightFlare © 2016-2017 TeslaCloud Studios
	Do not share or re-distribute before
	the framework is publicly released.
--]]
netstream.Hook("cwLoad3DTexts", function(data)
	cwSurfaceTexts.stored = data or {}
end)

netstream.Hook("cw3DText_Add", function(idx, data)
	cwSurfaceTexts.stored[idx] = data
end)

netstream.Hook("cw3DText_Remove", function(idx)
	cwSurfaceTexts.stored[idx] = nil
end)

netstream.Hook("cw3DText_Calculate", function()
	cwSurfaceTexts:RemoveAtTrace(cw.client:GetEyeTraceNoCursor())
end)

function cwSurfaceTexts:RemoveAtTrace(trace)
	if (!trace) then return false end

	local hitPos = trace.HitPos
	local traceStart = trace.StartPos

	for k, v in pairs(self.stored) do
		local pos = v.pos
		local normal = v.normal
		local ang = normal:Angle()
		local w, h = util.GetTextSize(cw.option:GetFont("large_3d_2d"), v.text)

		local startPos = pos - -ang:Right() * (w / 22) * v.scale
		local endPos = pos + -ang:Right() * (w / 22) * v.scale

		if (math.abs(math.abs(hitPos.z) - math.abs(pos.z)) < 5 * v.scale) then
			if (util.VectorsIntersect(traceStart, hitPos, startPos, endPos)) then
				netstream.Start("cw3DText_Remove", k)

				return true
			end
		end
	end

	return false
end