--- Defines the Resistance Uniform clothes item on `clothes_base`, which switches the wearer to the `group03` human
-- models and is sold to characters with the `m` flag.

ITEM.baseItem = 'clothes_base'
ITEM.name = 'Resistance Uniform'
ITEM.PrintName = '#ITEM_Resistance_Uniform'
ITEM.group = 'group03'
ITEM.weight = 3
ITEM.access = 'm'
ITEM.business = true
ITEM.protection = 0.1
ITEM.description = '#ITEM_Resistance_Uniform_Desc'

--- Swaps the player model to `models/humans/group03/male_02.mdl`
-- for players using `models/humans/group01/jasona.mdl`.
--
-- Other models fall back to the item's `replacement` or `group` model.
-- @return [String The replacement model path, or `nil`]
function ITEM:GetReplacement(player)
  if string.lower(player:GetModel()) == 'models/humans/group01/jasona.mdl' then
    return 'models/humans/group03/male_02.mdl'
  end
end
