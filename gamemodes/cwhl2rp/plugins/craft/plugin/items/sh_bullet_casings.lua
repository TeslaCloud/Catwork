--- Defines the Bullet Casings item (`bullet_casings`) of the Craft plugin, a crafting material used by the ammunition
-- blueprints.

ITEM.name = 'Bullet Casings'
ITEM.PrintName = '#Item_BulletCasings_Name'
ITEM.model = 'models/items/ammobox.mdl'
ITEM.weight = 0.5
ITEM.category = 'Materials'
ITEM.description = '#Item_BulletCasings_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
