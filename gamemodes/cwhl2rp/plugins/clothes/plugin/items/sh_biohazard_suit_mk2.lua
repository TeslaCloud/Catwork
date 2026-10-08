--- Defines the Biohazard Suit Mk.2 item (`biohazard_suit_mk2`), a heavier and more protective version of
-- `biohazard_suit` based on `clothes_base` that replaces the wearer's model with `industrial_uniform2` and is also
-- marked `radProtection`.

ITEM.baseItem = 'clothes_base'
ITEM.name = 'Biohazard Suit Mk.2'
ITEM.PrintName = '#ITEM_Biohazard_Suit_Mk2_Name'
ITEM.replacement = 'models/industrial_uniforms/industrial_uniform2.mdl'
ITEM.weight = 4
ITEM.access = 'm'
ITEM.business = false
ITEM.protection = 0.7
ITEM.description = '#ITEM_Biohazard_Suit_Mk2_Desc'
ITEM.radProtection = true

--- Returns the Mk.2 biohazard suit model for players using the `jasona` citizen model.
--
-- @return [String The replacement model, or `nil` to use the item's default `replacement`]
function ITEM:GetReplacement(player)
  if string.lower(player:GetModel()) == 'models/humans/group01/jasona.mdl' then
    return 'models/industrial_uniforms/industrial_uniform2.mdl'
  end
end
