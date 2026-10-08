--- Client-side Cable receivers of the Extra Clothing plugin that store the worn bodygroup and skin clothing sent by
-- the server.
--
-- The `BGClothes` and `SkinClothes` streams fill `cw.client.bgClothesData` and `cw.client.skinClothesData`, which the
-- items' `HasPlayerEquipped` reads on the client, and rebuild the inventory with `cw.inventory:Rebuild`.
--
-- Originally written for the Global Cooldown community.

cable.receive('BGClothes', function(clothesData)
  cw.client.bgClothesData = clothesData or {}

  cw.inventory:Rebuild()
end)

cable.receive('SkinClothes', function(clothesData, bNoRebuild)
  cw.client.skinClothesData = clothesData or {}

  if !bNoRebuild then
    cw.inventory:Rebuild()
  end
end)
