--- Defines the Biohazard Suit item (`biohazard_suit`), clothing based on `clothes_base` that replaces the wearer's
-- model with `industrial_uniform` and is marked `radProtection`, which shields the wearer from radiation.

--[[
models/barnes/refugee/female_72.mdl
--]]

ITEM.baseItem = 'clothes_base'
ITEM.name = 'Biohazard suit'
ITEM.PrintName = '#ITEM_Biohazard_Suit_Name'
ITEM.replacement = 'models/industrial_uniforms/industrial_uniform.mdl'
ITEM.weight = 3
ITEM.access = 'm'
ITEM.business = false
ITEM.protection = 0.4
ITEM.description = '#ITEM_Biohazard_Suit_Desc'
ITEM.radProtection = true

--- Returns the biohazard suit model for players using the `jasona` citizen model.
--
-- @return [String The replacement model, or `nil` to use the item's default `replacement`]
function ITEM:GetReplacement(player)
  if string.lower(player:GetModel()) == 'models/humans/group01/jasona.mdl' then
    return 'models/industrial_uniforms/industrial_uniform.mdl'
  end
end
