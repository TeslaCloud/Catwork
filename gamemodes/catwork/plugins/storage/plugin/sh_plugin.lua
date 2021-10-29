--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

--[[
	You don't have to do this, but I think it's nicer.
	Alternatively, you can simply use the PLUGIN variable.
--]]
PLUGIN:SetGlobalAlias("cwStorage")

--[[ You don't have to do this either, but I prefer to seperate the functions. --]]
util.Include("cl_plugin.lua")
util.Include("sv_plugin.lua")
util.Include("sv_hooks.lua")
util.Include("cl_hooks.lua")

cwStorage.containerList = {
	["models/props_wasteland/controlroom_storagecloset001a.mdl"] = {8, "Шкаф"},
	["models/props_wasteland/controlroom_storagecloset001b.mdl"] = {15, "Шкаф"},
	["models/props_wasteland/controlroom_filecabinet001a.mdl"] = {4, "Картотечный шкаф"},
	["models/props_wasteland/controlroom_filecabinet002a.mdl"] = {8, "Картотечный шкаф"},
	["models/props_c17/suitcase_passenger_physics.mdl"] = {5, "Кейс"},
	["models/props_junk/wood_crate001a_damagedmax.mdl"] = {8, "Деревянный ящик"},
	["models/props_junk/wood_crate001a_damaged.mdl"] = {8, "Деревянный ящик"},
	["models/props_interiors/furniture_desk01a.mdl"] = {4, "Письменный стол"},
	["models/props_c17/furnituredresser001a.mdl"] = {10, "Шкаф"},
	["models/props_c17/furnituredrawer001a.mdl"] = {8, "Шкаф"},
	["models/props_c17/furnituredrawer002a.mdl"] = {4, "Шкаф"},
	["models/props_c17/furniturefridge001a.mdl"] = {8, "Холодильник"},
	["models/props_c17/furnituredrawer003a.mdl"] = {8, "Шкаф"},
	["models/weapons/w_suitcase_passenger.mdl"] = {5, "Кейс"},
	["models/props_junk/trashdumpster01a.mdl"] = {15, "Мусорный ящик"},
	["models/props_junk/wood_crate001a.mdl"] = {8, "Деревянный ящик"},
	["models/props_junk/wood_crate002a.mdl"] = {10, "Деревянный ящик"},
	["models/items/ammocrate_rockets.mdl"] = {15, "Большой ящик"},
	["models/props_lab/filecabinet02.mdl"] = {8, "Картотечный шкаф"},
	["models/items/ammocrate_grenade.mdl"] = {15, "Большой ящик"},
	["models/props_junk/trashbin01a.mdl"] = {10, "Мусорка"},
	["models/props_c17/suitcase001a.mdl"] = {8, "Кейс"},
	["models/items/item_item_crate.mdl"] = {4, "Ящик"},
	["models/props_c17/oildrum001.mdl"] = {8, "Бочка"},
	["models/items/ammocrate_smg1.mdl"] = {15, "Большой ящик"},
	["models/items/ammocrate_ar2.mdl"] = {15, "Большой ящик"},
	["models/props_junk/cardboard_box001a.mdl"] = {4, "Коробка"},
	["models/props_junk/cardboard_box002a.mdl"] = {4, "Коробка"},
	["models/props_junk/cardboard_box003a.mdl"] = {3, "Коробка"},
	["models/props_wasteland/kitchen_fridge001a.mdl"] = {25, "Промышленный холодильник"},
	["models/props_lab/partsbin01.mdl"] = {4, "Почтовый ящик"},
	["models/props_office/file_cabinet_large_static.mdl"] = {25, "Большой картотечный шкаф"},
	["models/props/cs_militia/footlocker01_closed.mdl"] = {15, "Сундук"},
	["models/props_c17/furniturewashingmachine001a.mdl"] = {10, "Стиральная машина"},
	["models/props_c17/furniturestove001a.mdl"] = {10, "Плита"},
	["models/props_c17/lockers001a.mdl"] = {17, "Шкафчик"},
	["models/props_wasteland/cargo_container01.mdl"] = {1000, "Грузовой контейнер"},
	["models/props_c17/briefcase001a.mdl"] = {6, "Чемодан"},
	["models/props_combine/breendesk.mdl"] = {10, "Стол"},
	["models/props/cs_militia/crate_extrasmallmill.mdl"] = {15, "Коробка"},
	["models/props/cs_militia/crate_extralargemill.mdl"] = {15, "Коробка"},
	["models/props/cs_militia/crate_stackmill.mdl"] = {15, "Коробка"},
	["models/props/cs_militia/dryer.mdl"] = {10, "Сушилка"},
	["models/props_c17/furniturecupboard001a.mdl"] = {7, "Буфет"},
	["models/props_borealis/bluebarrel001.mdl"] = {10, "Бочка"},
	["models/props_wasteland/kitchen_counter001c.mdl"] = {17, "Кухонный стол"},
	["models/props_junk/plasticbucket001a.mdl"] = {4, "Банка из-под краски"},
	["models/items/boxmrounds.mdl"] = {5, "Коробка от патронов"},
	["models/items/boxsrounds.mdl"] = {3, "Коробка от патронов"},
	["models/props/cs_assault/dryer_box.mdl"] = {8, "Коробка"},
	["models/props/cs_assault/dryer_box2.mdl"] = {8, "Коробка"},
	["models/props/cs_assault/washer_box.mdl"] = {8, "Коробка"},
	["models/props/cs_assault/washer_box2.mdl"] = {8, "Коробка"},
	["models/props/cs_assault/box_stack1.mdl"] = {20, "Коробки"},
	["models/props/cs_assault/box_stack2.mdl"] = {20, "Коробки"},
	["models/props/cs_assault/moneypallet_washerdryer.mdl"] = {17, "Коробки"},
	["models/props/cs_militia/stove01.mdl"] = {15, "Плита"},
	["models/props/cs_office/cardboard_box01.mdl"] = {8, "Коробка"},
	["models/props/cs_office/cardboard_box02.mdl"] = {8, "Коробка"},
	["models/props/cs_office/cardboard_box03.mdl"] = {8, "Коробка"},
	["models/props/cs_office/file_cabinet1.mdl"] = {7, "Шкафчик"},
	["models/props/cs_office/file_cabinet1_group.mdl"] = {20, "Шкафчики"},
	["models/props/cs_office/file_cabinet2.mdl"] = {7, "Шкафчик"},
	["models/props/cs_office/file_cabinet3.mdl"] = {7, "Шкафчик"},
	["models/props/de_nuke/crate_extralarge.mdl"] = {6, "Коробка"},
	["models/props/de_nuke/crate_extrasmall.mdl"] = {6, "Коробка"},
	["models/props/de_nuke/crate_large.mdl"] = {15, "Коробка"},
	["models/props/de_nuke/crate_small.mdl"] = {8, "Коробка"},
	["models/props/de_nuke/file_cabinet1_group.mdl"] = {12, "Шкафчики"}
}
