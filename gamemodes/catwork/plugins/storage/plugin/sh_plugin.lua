--- Entry point of the Storage plugin, which turns props with certain models into containers that hold items and cash.
--
-- Sets the `cwStorage` global alias, includes the plugin's files and defines `cwStorage.containerList`, which maps
-- each container model to its weight capacity and its name.

--[[
  You don't have to do this, but I think it's nicer.
  Alternatively, you can simply use the PLUGIN variable.
--]]
PLUGIN:SetGlobalAlias('cwStorage')

--[[ You don't have to do this either, but I prefer to seperate the functions. --]]
util.Include('cl_plugin.lua')
util.Include('sv_plugin.lua')
util.Include('sv_hooks.lua')
util.Include('cl_hooks.lua')

cwStorage.containerList = {
  ['models/props_wasteland/controlroom_storagecloset001a.mdl'] = { 8, '#Container_Closet' },
  ['models/props_wasteland/controlroom_storagecloset001b.mdl'] = { 15, '#Container_Closet' },
  ['models/props_wasteland/controlroom_filecabinet001a.mdl'] = { 4, '#Container_FileCabinet' },
  ['models/props_wasteland/controlroom_filecabinet002a.mdl'] = { 8, '#Container_FileCabinet' },
  ['models/props_c17/suitcase_passenger_physics.mdl'] = { 5, '#Container_Suitcase' },
  ['models/props_junk/wood_crate001a_damagedmax.mdl'] = { 8, '#Container_WoodenCrate' },
  ['models/props_junk/wood_crate001a_damaged.mdl'] = { 8, '#Container_WoodenCrate' },
  ['models/props_interiors/furniture_desk01a.mdl'] = { 4, '#Container_Desk' },
  ['models/props_c17/furnituredresser001a.mdl'] = { 10, '#Container_Closet' },
  ['models/props_c17/furnituredrawer001a.mdl'] = { 8, '#Container_Closet' },
  ['models/props_c17/furnituredrawer002a.mdl'] = { 4, '#Container_Closet' },
  ['models/props_c17/furniturefridge001a.mdl'] = { 8, '#Container_Refrigerator' },
  ['models/props_c17/furnituredrawer003a.mdl'] = { 8, '#Container_Closet' },
  ['models/weapons/w_suitcase_passenger.mdl'] = { 5, '#Container_Suitcase' },
  ['models/props_junk/trashdumpster01a.mdl'] = { 15, '#Container_Dumpster' },
  ['models/props_junk/wood_crate001a.mdl'] = { 8, '#Container_WoodenCrate' },
  ['models/props_junk/wood_crate002a.mdl'] = { 10, '#Container_WoodenCrate' },
  ['models/items/ammocrate_rockets.mdl'] = { 15, '#Container_LargeCrate' },
  ['models/props_lab/filecabinet02.mdl'] = { 8, '#Container_FileCabinet' },
  ['models/items/ammocrate_grenade.mdl'] = { 15, '#Container_LargeCrate' },
  ['models/props_junk/trashbin01a.mdl'] = { 10, '#Container_TrashBin' },
  ['models/props_c17/suitcase001a.mdl'] = { 8, '#Container_Suitcase' },
  ['models/items/item_item_crate.mdl'] = { 4, '#Container_Crate' },
  ['models/props_c17/oildrum001.mdl'] = { 8, '#Container_Barrel' },
  ['models/items/ammocrate_smg1.mdl'] = { 15, '#Container_LargeCrate' },
  ['models/items/ammocrate_ar2.mdl'] = { 15, '#Container_LargeCrate' },
  ['models/props_junk/cardboard_box001a.mdl'] = { 4, '#Container_Box' },
  ['models/props_junk/cardboard_box002a.mdl'] = { 4, '#Container_Box' },
  ['models/props_junk/cardboard_box003a.mdl'] = { 3, '#Container_Box' },
  ['models/props_wasteland/kitchen_fridge001a.mdl'] = { 25, '#Container_IndustrialRefrigerator' },
  ['models/props_lab/partsbin01.mdl'] = { 4, '#Container_Mailbox' },
  ['models/props_office/file_cabinet_large_static.mdl'] = { 25, '#Container_LargeFileCabinet' },
  ['models/props/cs_militia/footlocker01_closed.mdl'] = { 15, '#Container_Chest' },
  ['models/props_c17/furniturewashingmachine001a.mdl'] = { 10, '#Container_WashingMachine' },
  ['models/props_c17/furniturestove001a.mdl'] = { 10, '#Container_Stove' },
  ['models/props_c17/lockers001a.mdl'] = { 17, '#Container_Locker' },
  ['models/props_wasteland/cargo_container01.mdl'] = { 1000, '#Container_CargoContainer' },
  ['models/props_c17/briefcase001a.mdl'] = { 6, '#Container_Briefcase' },
  ['models/props_combine/breendesk.mdl'] = { 10, '#Container_Table' },
  ['models/props/cs_militia/crate_extrasmallmill.mdl'] = { 15, '#Container_Box' },
  ['models/props/cs_militia/crate_extralargemill.mdl'] = { 15, '#Container_Box' },
  ['models/props/cs_militia/crate_stackmill.mdl'] = { 15, '#Container_Box' },
  ['models/props/cs_militia/dryer.mdl'] = { 10, '#Container_Dryer' },
  ['models/props_c17/furniturecupboard001a.mdl'] = { 7, '#Container_Cupboard' },
  ['models/props_borealis/bluebarrel001.mdl'] = { 10, '#Container_Barrel' },
  ['models/props_wasteland/kitchen_counter001c.mdl'] = { 17, '#Container_KitchenCounter' },
  ['models/props_junk/plasticbucket001a.mdl'] = { 4, '#Container_PaintCan' },
  ['models/items/boxmrounds.mdl'] = { 5, '#Container_AmmoBox' },
  ['models/items/boxsrounds.mdl'] = { 3, '#Container_AmmoBox' },
  ['models/props/cs_assault/dryer_box.mdl'] = { 8, '#Container_Box' },
  ['models/props/cs_assault/dryer_box2.mdl'] = { 8, '#Container_Box' },
  ['models/props/cs_assault/washer_box.mdl'] = { 8, '#Container_Box' },
  ['models/props/cs_assault/washer_box2.mdl'] = { 8, '#Container_Box' },
  ['models/props/cs_assault/box_stack1.mdl'] = { 20, '#Container_Boxes' },
  ['models/props/cs_assault/box_stack2.mdl'] = { 20, '#Container_Boxes' },
  ['models/props/cs_assault/moneypallet_washerdryer.mdl'] = { 17, '#Container_Boxes' },
  ['models/props/cs_militia/stove01.mdl'] = { 15, '#Container_Stove' },
  ['models/props/cs_office/cardboard_box01.mdl'] = { 8, '#Container_Box' },
  ['models/props/cs_office/cardboard_box02.mdl'] = { 8, '#Container_Box' },
  ['models/props/cs_office/cardboard_box03.mdl'] = { 8, '#Container_Box' },
  ['models/props/cs_office/file_cabinet1.mdl'] = { 7, '#Container_Locker' },
  ['models/props/cs_office/file_cabinet1_group.mdl'] = { 20, '#Container_Lockers' },
  ['models/props/cs_office/file_cabinet2.mdl'] = { 7, '#Container_Locker' },
  ['models/props/cs_office/file_cabinet3.mdl'] = { 7, '#Container_Locker' },
  ['models/props/de_nuke/crate_extralarge.mdl'] = { 6, '#Container_Box' },
  ['models/props/de_nuke/crate_extrasmall.mdl'] = { 6, '#Container_Box' },
  ['models/props/de_nuke/crate_large.mdl'] = { 15, '#Container_Box' },
  ['models/props/de_nuke/crate_small.mdl'] = { 8, '#Container_Box' },
  ['models/props/de_nuke/file_cabinet1_group.mdl'] = { 12, '#Container_Lockers' }
}
