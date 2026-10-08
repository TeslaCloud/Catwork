--- Server-side hooks of the Map Scenes plugin that load the saved scenes on startup, pick a random one for each joining
-- player and add its position to that player's PVS.

--- Called when a player's data stream info should be sent; picks a random map scene for them and sends it.
--
-- @param player [Player The player receiving the data]
function cwMapScene:PlayerSendDataStreamInfo(player)
  if #self.storedList > 0 then
    player.cwMapScene = self.storedList[math.random(1, #self.storedList)]

    if player.cwMapScene then
      netstream.Start(player, 'MapScene', player.cwMapScene)
    end
  end
end

--- Called when a player's visibility is set up; adds their map scene's position to their PVS.
--
-- @param player [Player The player whose PVS is built]
function cwMapScene:SetupPlayerVisibility(player)
  if player.cwMapScene then
    AddOriginToPVS(player.cwMapScene.position)
  end
end

--- Called after Catwork has loaded all of its entities; loads the saved map scenes.
function cwMapScene:ClockworkInitPostEntity()
  cwMapScene:LoadMapScenes()
end
