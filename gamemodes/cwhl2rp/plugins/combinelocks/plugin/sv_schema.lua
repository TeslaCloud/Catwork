local PLUGIN = PLUGIN

function Schema:PlayerHasCombineLockAccess(client, access, rank)
	if Schema:PlayerIsCombine(client) then
		if rank then
			return !Schema:IsPlayerCombineRank(client, rank)
		else
			return true
		end
	elseif (client:HasItemByID("combine_lock_access_"..tostring(access))) then
		return true
	elseif (client:HasItemByID("combine_lock_access_x")) then
		return true
	end

	return false
end

function Schema:ApplyCombineLock(entity, position, angles, access, rank, color)
	local combineLock = ents.Create("cw_combinelock")
	combineLock:SetVelocity(Vector())

	if IsValid(combineLock:GetPhysicsObject()) then
		combineLock:GetPhysicsObject():EnableMotion(false)
	end

	combineLock:SetParent(entity)
	combineLock:SetDoor(entity)

	if (position) then
		if (type(position) == "table") then
			combineLock:SetLocalPos(Vector(-1.0313, 43.7188, -1.2258))
			combineLock:SetPos(combineLock:GetPos() + (position.HitNormal * 4))
		else
			combineLock:SetPos(position)
		end
	end

	if (angles) then
		combineLock:SetAngles(angles)
	end

	if (color) then
		combineLock:SetOverrideColor(color)
	end

	combineLock:Spawn()
	combineLock:SetAccess(access)
	combineLock:SetCPRank(rank)

	if (IsValid(combineLock)) then
		return combineLock
	end
end

function PLUGIN:SaveCombineLocks()
	local cmbLocks = {}

	for k, v in pairs(ents.FindByClass("cw_combinelock")) do
		if (IsValid(v.entity)) then
			cmbLocks[#cmbLocks + 1] = {
				doorID = v.entity:MapCreationID(),
				key = cw.entity:QueryProperty(v, "key"),
				locked = v:IsLocked(),
				angles = v:GetLocalAngles(),
				position = v:GetLocalPos(),
				uniqueID = cw.entity:QueryProperty(v, "uniqueID"),
				doorPosition = v.entity:GetPos(),
				access = v:GetAccess(),
				rank = v:GetCPRank(),
				color = v.overrideColor
			}
		end
	end

	cw.core:SaveSchemaData("plugins/combinelocks/"..game.GetMap(), cmbLocks)
end
function PLUGIN:LoadCombineLocks()
	local cmbLocks = cw.core:RestoreSchemaData("plugins/combinelocks/"..game.GetMap())

	for k, v in pairs(cmbLocks) do
		local entity = ents.GetMapCreatedEntity(v.doorID)

		if (IsValid(entity)) then
			local combineLock = Schema:ApplyCombineLock(entity)

			if (combineLock) then
				cw.player:GivePropertyOffline(v.key, v.uniqueID, entity)

				combineLock:SetLocalAngles(v.angles)
				combineLock:SetLocalPos(v.position)
				combineLock:SetAccess(v.access)
				combineLock:SetCPRank(v.rank)
				combineLock:SetOverrideColor(v.color)

				if (!v.locked) then
					combineLock:Unlock()
				else
					combineLock:Lock()
				end
			end
		end
	end
end