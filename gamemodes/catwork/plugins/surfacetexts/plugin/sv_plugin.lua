--[[
	LightFlare © 2016-2017 TeslaCloud Studios
	Do not share or re-distribute before
	the framework is publicly released.
--]]

function cwSurfaceTexts:Save()
	cw.core:SaveSchemaData("plugins/3dtexts/"..game.GetMap(), {self.stored, self.count})
end

function cwSurfaceTexts:Load()
	local loaded = cw.core:RestoreSchemaData("plugins/3dtexts/"..game.GetMap(), {})

	self.stored = loaded[1] or {}
	self.count = loaded[2] or 0
end

function cwSurfaceTexts:AddText(data)
	if (!data or !data.text or !data.pos or !data.angle or !data.style or !data.scale) then return end

	self.count = (self.count or 0) + 1

	self.stored[self.count] = data

	self:Save()

	netstream.Start(nil, "cw3DText_Add", self.count, data)
end

function cwSurfaceTexts:Remove(player)
	if (player:IsAdmin()) then
		netstream.Start(player, "cw3DText_Calculate", true)
	end
end

netstream.Hook("cw3DText_Remove", function(player, idx)
	if (player:IsAdmin()) then
		cwSurfaceTexts.stored[idx] = nil
		cwSurfaceTexts:Save()

		netstream.Start(nil, "cw3DText_Remove", idx)

		cw.player:Notify(player, "You have removed a 3D text.")
	end
end)