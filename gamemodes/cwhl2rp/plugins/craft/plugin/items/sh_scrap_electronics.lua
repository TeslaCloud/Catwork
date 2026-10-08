--- Defines the Scrap Electronics item (`scrap_electronics`) of the Craft plugin, a crafting material used by the
-- flashlight blueprint and to make `refined_electronics`.

ITEM.name = 'Scrap Electronics'
ITEM.PrintName = '#Item_ScrapElectronics_Name'
ITEM.model = 'models/props_lab/reciever01d.mdl'
ITEM.weight = 0.4
ITEM.category = 'Materials'
ITEM.description = '#Item_ScrapElectronics_Description'

--- Lets the item be dropped, with no extra effect.
function ITEM:OnDrop(player, position) end
