--[[
	Flux © 2016-2017 TeslaCloud Studios
	Do not share or re-distribute before
	the framework is publicly released.
--]]

-- Disable default Sandbox persistence.
hook.Remove("ShutDown", "SavePersistenceOnShutdown")
hook.Remove("PersistenceSave", "PersistenceSave")
hook.Remove("PersistenceLoad", "PersistenceLoad")
hook.Remove("InitPostEntity", "PersistenceInit")

local whitelistedEntities = {
	"prop_physics",
	"prop_physics_multiplayer",
	"prop_ragdoll",
	"edit_",
	"gmod_"
}


function cwStaticEnts:PlayerMakeStatic(player, bIsStatic)
	if (!IsValid(player)) then return end

	if ((bIsStatic and !player:IsAdmin()) or (!bIsStatic and !player:IsAdmin())) then
		cw.player:Notify(player, "You do not have access to this command, "..player:Name())

		return
	end

	local trace = player:GetEyeTraceNoCursor()
	local entity = trace.Entity

	if (!IsValid(entity)) then
		cw.player:Notify(player, "#Err_NotValidEntity")

		return
	end

	local entClass = entity:GetClass()

	for k, v in ipairs(whitelistedEntities) do
		if (entClass:find(v)) then
			entClass = true

			break
		end
	end

	if (entClass != true) then
		cw.player:Notify(player, "#Err_CannotStaticThis")

		return
	end

	local isStatic = entity:GetPersistent()

	if (bIsStatic and isStatic) then
		cw.player:Notify(player, "#Err_AlreadyStatic")

		return
	elseif (!bIsStatic and !isStatic) then
		cw.player:Notify(player, "#Err_NotStatic")

		return
	end

	entity:SetPersistent(bIsStatic)

	cw.player:Notify(player, (bIsStatic and "#Static_Added") or "#Static_Removed")
end

function cwStaticEnts:ShutDown()
	hook.Run("PersistenceSave")
end

function cwStaticEnts:PersistenceSave()
	local entities = {}

	for k, v in ipairs(ents.GetAll()) do
		if (v:GetPersistent()) then
			table.insert(entities, v)
		end
	end

	local toSave = duplicator.CopyEnts(entities)

	if (!istable(toSave)) then return end

	cw.core:SaveSchemaData("static", toSave, true)
end

function cwStaticEnts:PersistenceLoad()
	local loaded = cw.core:RestoreSchemaData("static", {}, true)

	if (!istable(loaded)) then return end
	if (!loaded.Entities) then return end
	if (!loaded.Constraints) then return end

	local entities, constraints = duplicator.Paste(nil, loaded.Entities, loaded.Constraints)

	-- Restore any custom data the static entities might have had.
	for k, v in pairs(entities) do
		local entData = loaded.Entities[k]

		if (entData) then
			table.Merge(v:GetTable(), entData)
		end
	end

	for k, v in pairs(entities) do
		v:SetPersistent(true)
	end
end

function cwStaticEnts:InitPostEntity()
	hook.Run("PersistenceLoad")
end