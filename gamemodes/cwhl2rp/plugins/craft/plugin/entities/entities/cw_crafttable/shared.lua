--- Shared definition of the `cw_crafttable` entity of the Craft plugin, the workbench that is both the default crafting
-- station and the base of the other `cw_craft_*` stations, which it marks with `IsCraft`.

DEFINE_BASECLASS('base_gmodentity')

ENT.Type = 'anim'
ENT.Author = 'AleXXX_007'
ENT.PrintName = '#Craft_Table_Bench'

ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.UsableInVehicle = false
ENT.PhysgunDisabled = false
ENT.IsCraft = true

ENT.Model = 'models/mosi/fallout4/furniture/workstations/workshopbench.mdl'
ENT.Category = '#Craft_Table_Category'
