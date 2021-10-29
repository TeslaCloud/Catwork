--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

do
	local playerMeta = FindMetaTable("Player")
	local entMeta = FindMetaTable("Entity")
	entMeta.oldSetModel = entMeta.oldSetModel or entMeta.SetModel

	function entMeta:IsStuck()
		return util.TraceEntity({
			start = self:GetPos(),
			endpos = self:GetPos(),
			filter = self
		}, self).StartSolid
	end

	function playerMeta:SetModel(strPath)
		local oldModel = self:GetModel()

		hook.Run("PlayerModelChanged", self, strPath, oldModel)

		if (SERVER) then
			netstream.Start(nil, "PlayerModelChanged", self:EntIndex(), strPath, oldModel)
		end

		return self:oldSetModel(strPath)
	end

	local animCache = {}

	function GM:PlayerModelChanged(player, strNewModel, strOldModel)
		if (CLIENT) then
			player:SetIK(false)
		end

		if (!animCache[strNewModel]) then
			animCache[strNewModel] = cw.animation:GetTable(strNewModel)
		end

		player.cwAnimTable = animCache[strNewModel]
	end

	local vectorAngle = FindMetaTable("Vector").Angle
	local normalizeAngle = math.NormalizeAngle

	function GM:CalcMainActivity(player, velocity)
		player:SetPoseParameter("move_yaw", normalizeAngle(vectorAngle(velocity)[2] - player:EyeAngles()[2]))

		player.CalcIdeal = ACT_MP_STAND_IDLE
		player.CalcSeqOverride = -1

		local baseClass = self.BaseClass

		if (baseClass:HandlePlayerNoClipping(player, velocity) or
			baseClass:HandlePlayerDriving(player) or
			baseClass:HandlePlayerVaulting(player, velocity) or
			baseClass:HandlePlayerJumping(player, velocity) or
			baseClass:HandlePlayerSwimming(player, velocity) or
			baseClass:HandlePlayerDucking(player, velocity)) then
		else
			local len2D = velocity:Length2D()

			if (len2D > 150) then
				player.CalcIdeal = ACT_MP_RUN
			elseif (len2D > 0.5) then
				player.CalcIdeal = ACT_MP_WALK
			end
		end

		local forcedAnimation = player:GetForcedAnimation()

		if (forcedAnimation) then
			local sequence = forcedAnimation.animation

			if (isstring(sequence)) then
				sequence = player:LookupSequence(sequence)
			end

			if (sequence != -1) then
				if (forcedAnimation.OnAnimate) then
					forcedAnimation.OnAnimate(player)
					forcedAnimation.OnAnimate = nil
				end

				return sequence or ACT_IDLE, sequence or -1
			end
		end

		player.m_bWasOnGround = player:IsOnGround()
		player.m_bWasNoclipping = (player:GetMoveType() == MOVETYPE_NOCLIP and !player:InVehicle())

		return player.CalcIdeal, player.CalcSeqOverride
	end
end

-- Called when to translate player activities.
function GM:TranslateActivity(player, act)
	local animations = player.cwAnimTable

	if (!animations) then
		return self.BaseClass:TranslateActivity(player, act)
	end

	if (player:InVehicle()) then
		local vehicle = player:GetVehicle()
		local class = vehicle:GetClass()

		if (animations["vehicle"] and animations["vehicle"][class]) then
			local animation = "sitchair1"

			if (isstring(animation)) then
				player.CalcSeqOverride = player:LookupSequence(animation)

				return
			else
				return animation
			end
		else			
			local animation = "sitchair1"

			if (isstring(animation)) then
				player.CalcSeqOverride = player:LookupSequence(animation)

				return
			end

			return animation
		end
	elseif (player:OnGround()) then
		local weapon = player:GetActiveWeapon()
		local holdType = "normal"
		local alwaysLowered = false

		if (IsValid(weapon)) then
			holdType = cw.animation:GetWeaponHoldType(player, weapon)

			if (weapon:GetClass() == "cw_keys") then
				alwaysLowered = true
			end
		end

		if (animations[holdType] and animations[holdType][act]) then
			local animation = animations[holdType][act]

			if (istable(animation)) then
				if (!alwaysLowered and player:IsWeaponRaised()) then
					animation = animation[2]
				else
					animation = animation[1]
				end
			end

			if (isstring(animation)) then
				player.CalcSeqOverride = player:LookupSequence(animation)
			else
				return animation
			end
		end
	elseif (animations["normal"]["glide"]) then
		return animations["normal"]["glide"]
	end
end

-- Called when the animation event is supposed to be done.
-- NutScript / Clockwork hybrid kinda.
function GM:DoAnimationEvent(player, event, data)
	local model = player:GetModel()

	if (string.find(model, "/player/")) then
		return self.BaseClass:DoAnimationEvent(player, event, data)
	end

	local weapon = player:GetActiveWeapon()

	if (IsValid(weapon)) then
		local weaponHoldType = cw.animation:GetWeaponHoldType(player, weapon)

		if (event == PLAYERANIMEVENT_ATTACK_PRIMARY) then
			local attackAnimation = cw.animation:GetForModel(model, weaponHoldType, "attack", true)

			player:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, attackAnimation or ACT_GESTURE_RANGE_ATTACK_SMG1, true)

			return ACT_VM_PRIMARYATTACK
		elseif (event == PLAYERANIMEVENT_ATTACK_SECONDARY) then
			local attackAnimation = cw.animation:GetForModel(model, weaponHoldType, "attack", true)

			player:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, attackAnimation or ACT_GESTURE_RANGE_ATTACK_SMG1, true)

			return ACT_VM_SECONDARYATTACK
		elseif (event == PLAYERANIMEVENT_RELOAD) then
			local reloadAnimation = cw.animation:GetForModel(model, weaponHoldType, "reload", true)

			player:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, reloadAnimation or ACT_GESTURE_RELOAD_SMG1, true)

			return ACT_INVALID
		elseif (event == PLAYERANIMEVENT_JUMP) then
			-- manually set standard gmod vars.
			player.m_bJumping = true
			player.m_bFistJumpFrame = true
			player.m_flJumpStartTime = CurTime()

			player:AnimRestartMainSequence()

			return ACT_INVALID
		elseif (event == PLAYERANIMEVENT_CANCEL_RELOAD) then
			player:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD)

			return ACT_INVALID
		end
	end
end

function GM:MouthMoveAnimation(player)
	if (config.GetVal("enable_mouth_move")) then
		return self.BaseClass:MouthMoveAnimation(player)
	else
		return
	end
end

-- Called when a player's footstep sound should be played.
function GM:PlayerFootstep(player, position, foot, sound, volume, recipientFilter)
	return true
end

-- Autorefresh support.
-- Called when the gamemode has been reloaded by AutoRefresh.
function GM:OnReloaded()
	cw.Reloaded = true

	if (SERVER) then
		cw.database:OnConnected()
		print("[Catwork] OnReloaded hook called serverside!")
	else
		cw.theme:Get():CreateFonts()
			cw.theme:CopySkin()
		cw.theme:Get():Initialize()

		cw.core:PrintColoredText(
			cw.core:GetLogTypeColor(LOGTYPE_MINOR), "Clockwork has AutoRefreshed clientside!"
		)
	end
end
