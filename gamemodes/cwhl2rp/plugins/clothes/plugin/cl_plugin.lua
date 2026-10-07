--[[
  © 2016 TeslaCloud Studios.
  Private code for Global Cooldown community.
  Stealing Lua cache is not nice lol.
  get a life kiddos.
--]]

netstream.Hook('BGClothes', function(clothesData)
  cw.client.bgClothesData = clothesData or {}

  cw.inventory:Rebuild()
end)

netstream.Hook('SkinClothes', function(clothesData, bNoRebuild)
  cw.client.skinClothesData = clothesData or {}

  if !bNoRebuild then
    cw.inventory:Rebuild()
  end
end)
