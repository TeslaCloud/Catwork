--[[
	LightFlare © 2016-2017 TeslaCloud Studios
	Do not share or re-distribute before
	the framework is publicly released.
--]]

function cwSurfaceTexts:PlayerSendDataStreamInfo(player)
	netstream.Start(player, "cwLoad3DTexts", self.stored)
end

function cwSurfaceTexts:ClockworkInitPostEntity()
	self:Load()
end

function cwSurfaceTexts:SaveData()
	self:Save()
end