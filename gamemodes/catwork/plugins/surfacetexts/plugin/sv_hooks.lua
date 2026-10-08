--- Server-side hooks of the Surface Texts plugin that load and save the texts and send them to joining players.
--
-- Backported from the [Flux](https://github.com/TeslaCloud/flux-ce) project.

--- Called when a player's data stream info should be sent; sends them every surface text.
--
-- @param player [Player The player receiving the data]
function cwSurfaceTexts:PlayerSendDataStreamInfo(player)
  netstream.Start(player, 'cwLoad3DTexts', self.stored)
end

--- Called after Catwork has loaded all of its entities; loads the saved surface texts.
function cwSurfaceTexts:ClockworkInitPostEntity()
  self:Load()
end

--- Called when Catwork saves its data; saves the surface texts.
function cwSurfaceTexts:SaveData()
  self:Save()
end
