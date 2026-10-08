--- Client-side Cable receiver of the Map Scenes plugin, which keeps the scene sent in the `MapScene` message as the
-- one shown behind the character menu.

cable.receive('MapScene', function(data)
  cwMapScene.curStored = data
end)
