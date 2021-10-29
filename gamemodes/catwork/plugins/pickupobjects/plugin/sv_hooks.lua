--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

-- Called when a player's character has unloaded.
function cwPickupObjects:PlayerCharacterUnloaded(player)
	self:ForceDropEntity(player)
end

-- Called to get the entity that a player is holding.
function cwPickupObjects:PlayerGetHoldingEntity(player)
	if (IsValid(player.cwHoldingEnt)) then
		return player.cwHoldingEnt
	end
end

-- Called when a player attempts to throw a punch.
function cwPickupObjects:PlayerCanThrowPunch(player)
	if (IsValid(player.cwHoldingEnt) or (player.nextPunchTime
	and player.nextPunchTime >= CurTime())) then
		return false
	end
end

-- Called when a player's weapons should be given.
function cwPickupObjects:PlayerGiveWeapons(player)
	if (config.Get("take_physcannon"):Get()) then
		cw.player:TakeSpawnWeapon(player, "weapon_physcannon")
	end
end

-- Called to get whether an entity is being held.
function cwPickupObjects:GetEntityBeingHeld(entity)
	if (IsValid(entity.cwHoldingGrab) and !entity:IsPlayer()) then
		return true
	end
end

-- Called when Clockwork config has changed.
function cwPickupObjects:ClockworkConfigChanged(key, data, previousValue, newValue)
	if (key == "take_physcannon") then
		for k, v in ipairs(_player.GetAll()) do
			if (newValue) then
				cw.player:TakeSpawnWeapon(v, "weapon_physcannon")
			else
				cw.player:GiveSpawnWeapon(v, "weapon_physcannon")
			end
		end
	end
end

-- Called when a player's ragdoll attempts to take damage.
function cwPickupObjects:PlayerRagdollCanTakeDamage(player, ragdoll, inflictor, attacker, hitGroup, damageInfo)
	if (ragdoll.cwNextTakeDmg and CurTime() < ragdoll.cwNextTakeDmg) then
		return false
	elseif (IsValid(ragdoll.cwHoldingGrab)) then
		if (!damageInfo:IsExplosionDamage() and !damageInfo:IsBulletDamage()) then
			if (!damageInfo:IsDamageType(DMG_CLUB) and !damageInfo:IsDamageType(DMG_SLASH)) then
				return false
			end
		end
	end
end

-- Called when a player enters a vehicle.
function cwPickupObjects:PlayerEnteredVehicle(player, vehicle, class)
	if (IsValid(player.cwHoldingEnt) and player.cwHoldingEnt == vehicle) then
		self:ForceDropEntity(player)
	end
end

-- Called when a player attempts to get up.
function cwPickupObjects:PlayerCanGetUp(player)
	if (player:GetNetVar("IsDragged")) then
		return false
	end
end

-- Called when a player's shared variables should be set.
function cwPickupObjects:OnePlayerSecond(player, curTime)
	if (player:IsRagdolled() and cw.player:GetUnragdollTime(player)) then
		local entity = player:GetRagdollEntity()

		if (IsValid(entity)) then
			if (IsValid(entity.cwHoldingGrab) or entity:IsBeingHeld()) then
				cw.player:PauseUnragdollTime(player)

				player:SetNetVar("IsDragged", true)
			elseif (player:GetNetVar("IsDragged")) then
				cw.player:StartUnragdollTime(player)

				player:SetNetVar("IsDragged", false)
			end
		else
			player:SetNetVar("IsDragged", false)
		end
	else
		player:SetNetVar("IsDragged", false)
	end
end

-- Called when a player presses a key.
function cwPickupObjects:KeyPress(player, key)
	if (player:IsUsingHands()) then
		if (!IsValid(player.cwHoldingEnt)) then
			if (key == IN_ATTACK2) then
				local trace = player:GetEyeTraceNoCursor()
				local entity = trace.Entity
				local bCanPickup = nil

				if (IsValid(entity) and trace.HitPos:Distance(player:GetShootPos()) <= 96
				and !entity:IsPlayer() and !entity:IsNPC()) then
					if (hook.Run("CanHandsPickupEntity", player, entity, trace)) then
						bCanPickup = true
					end

					local bIsDoor = cw.entity:IsDoor(entity)

					if (bCanPickup and !bIsDoor and !player:InVehicle()) then
						self:ForcePickup(player, entity, trace)
					elseif (bIsDoor) then
						local hands = player:GetActiveWeapon()

						hands:SecondaryAttack()
					end
				end
			end
		elseif (key == IN_ATTACK) then
			self:ForceThrowEntity(player)
		elseif (key == IN_RELOAD) then
			self:ForceDropEntity(player)
		end
	end
end

-- Called when a player attempts to pickup an object.
function cwPickupObjects:CanHandsPickupEntity(player, entity, trace)
	if (entity:GetClass() == "cw_plant" or entity:GetClass() == "cw_garbage") then
		return false
	end

	if (IsValid(entity:GetPhysicsObject()) and entity:GetSolid() == SOLID_VPHYSICS) then
		if (entity:GetClass() == "prop_ragdoll" or entity:GetPhysicsObject():GetMass() <= 100 + cw.attributes:Fraction(player, ATB_STRENGTH, 100)) then
			if (entity:GetPhysicsObject():IsMoveable() and !IsValid(entity.cwHoldingGrab)) then
				if (!entity.noHandsPickup) then
					return true
				end
			end
		end
	end
end
