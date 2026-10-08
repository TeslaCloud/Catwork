--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

ITEM.baseItem = 'clothes_base'
ITEM.name = 'Poncho'
ITEM.PrintName = '#Item_VortPoncho_PrintName'
ITEM.replacement = 'models/vortigaunt_ozaxi.mdl'
ITEM.weight = 2
ITEM.access = 'v'
ITEM.whitelist = {
  FACTION_VORT
}
ITEM.business = true
ITEM.category = 'Reusables'
ITEM.description = '#Item_VortPoncho_Description'

--- Swaps the player model to `models/vortigaunt_ozaxi.mdl`
-- for players using `models/vortigaunt.mdl`.
--
-- Other models fall back to the item's `replacement` or `group` model.
-- @return [String The replacement model path, or `nil`]
function ITEM:GetReplacement(player)
  if string.lower(player:GetModel()) == 'models/vortigaunt.mdl' then
    return 'models/vortigaunt_ozaxi.mdl'
  end
end
