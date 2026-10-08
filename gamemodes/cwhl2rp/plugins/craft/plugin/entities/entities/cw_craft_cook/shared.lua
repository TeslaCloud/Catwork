--- Defines the `cw_craft_cook` entity of the Craft plugin, the cooking stove crafting station, which is based on
-- `cw_crafttable` and only changes its name and model so that the craft menu lists the cooking blueprints made at it.

DEFINE_BASECLASS('base_gmodentity')

ENT.Base = 'cw_crafttable'
ENT.Type = 'anim'
ENT.Author = 'AleXXX_007'
ENT.PrintName = '#Craft_Table_Cook'

ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.UsableInVehicle = false
ENT.PhysgunDisabled = false
ENT.IsCraft = true

ENT.Model = 'models/mosi/fallout4/furniture/workstations/cookingstation01.mdl'
ENT.Category = '#Craft_Table_Category'
