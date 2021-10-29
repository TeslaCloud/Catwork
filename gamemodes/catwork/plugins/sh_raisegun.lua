--[[
	Flux © 2016-2017 TeslaCloud Studios
	Do not share or re-distribute before
	the framework is publicly released.
--]]

PLUGIN.name = "Raise Gun"
PLUGIN.description = "Allows players to raise and lower their weapons."
PLUGIN.author = "Mr. Meow"
PLUGIN.compatibility = "1.2"

local playerMeta = FindMetaTable("Player")
local blockedWeapons = {
	"weapon_physgun",
	"gmod_tool",
	"gmod_camera",
	"weapon_physcannon",
	"cw_keys"
}

local rotationTranslate = {
	["default"] = Angle(30, -30, -25),
	["weapon_fists"] = Angle(30, -30, -50),
	["cw_hands"] = Angle(30, -30, -50)
}

function playerMeta:SetWeaponRaised(bIsRaised)
	if (SERVER) then
		self:SetDTBool(BOOL_WEAPON_RAISED, bIsRaised)

		hook.Run("OnWeaponRaised", self, self:GetActiveWeapon(), bIsRaised)
	end
end

function playerMeta:IsWeaponRaised()
	local weapon = self:GetActiveWeapon()

	if (!IsValid(weapon)) then
		return false
	end

	if (table.HasValue(blockedWeapons, weapon:GetClass())) then
		return true
	end

	local shouldRaise = hook.Run("ShouldWeaponBeRaised", self, weapon)

	if (shouldRaise) then
		return shouldRaise
	end

	return self:GetDTBool(BOOL_WEAPON_RAISED)
end

function playerMeta:ToggleWeaponRaised()
	if (hook.Run("CanWeaponBeToggled", self, self:GetActiveWeapon())) then
		if (self:IsWeaponRaised()) then
			self:SetWeaponRaised(false)	
		else
			self:SetWeaponRaised(true)
		end
	end
end

function PLUGIN:OnWeaponRaised(player, weapon, bIsRaised)
	if (IsValid(weapon)) then
		local curTime = CurTime()

		hook.Run("UpdateWeaponRaised", player, weapon, bIsRaised, curTime)
	end
end

function PLUGIN:UpdateWeaponRaised(player, weapon, bIsRaised, curTime)
	if (bIsRaised or table.HasValue(blockedWeapons, weapon:GetClass())) then
		weapon:SetNextPrimaryFire(curTime)
		weapon:SetNextSecondaryFire(curTime)

		if (weapon.OnRaised) then
			weapon:OnRaised(player, curTime)
		end
	else
		weapon:SetNextPrimaryFire(curTime + 60)
		weapon:SetNextSecondaryFire(curTime + 60)

		if (weapon.OnLowered) then
			weapon:OnLowered(player, curTime)
		end
	end
end

function PLUGIN:PlayerThink(player, curTime)
	local weapon = player:GetActiveWeapon()

	if (IsValid(weapon)) then
		if (!player:IsWeaponRaised()) then
			weapon:SetNextPrimaryFire(curTime + 60)
			weapon:SetNextSecondaryFire(curTime + 60)
		end
	end
end

function PLUGIN:KeyPress(player, key)
	if (key == IN_RELOAD) then
		timer.Create("WeaponRaise"..player:SteamID(), 1, 1, function()
			player:ToggleWeaponRaised()
		end)
	end
end

function PLUGIN:KeyRelease(player, key)
	if (key == IN_RELOAD) then
		timer.Remove("WeaponRaise"..player:SteamID())
	end
end

function PLUGIN:ModelWeaponRaised(player, model)
	return player:IsWeaponRaised()
end

function PLUGIN:PlayerSwitchWeapon(player, oldWeapon, newWeapon)
	if (player:IsWeaponRaised()) then
		player:SetWeaponRaised(false)
	end
end

function PLUGIN:PlayerSetupDataTables(player)
	player:DTVar("Bool", BOOL_WEAPON_RAISED, "WeaponRaised")
end

if (CLIENT) then
	function PLUGIN:CalcViewModelView(weapon, viewModel, oldEyePos, oldEyeAngles, eyePos, eyeAngles)
		if (!IsValid(weapon)) then
			return
		end

		local targetVal = 0

		if (!cw.client:IsWeaponRaised()) then
			targetVal = 100
		end

		local fraction = (cw.client.curRaisedFrac or 0) / 100
		local rotation = rotationTranslate[weapon:GetClass()] or rotationTranslate["default"]

		eyeAngles:RotateAroundAxis(eyeAngles:Up(), rotation.p * fraction)
		eyeAngles:RotateAroundAxis(eyeAngles:Forward(), rotation.y * fraction)
		eyeAngles:RotateAroundAxis(eyeAngles:Right(), rotation.r * fraction)

		cw.client.curRaisedFrac = Lerp(FrameTime() * 2, cw.client.curRaisedFrac or 0, targetVal)

		viewModel:SetAngles(eyeAngles)

		if (weapon.GetViewModelPosition) then
			local position, angles = weapon:GetViewModelPosition(eyePos, eyeAngles)

			oldEyePos = position or oldEyePos
			eyeAngles = angles or eyeAngles
		end

		if (weapon.CalcViewModelView) then
			local position, angles = weapon:CalcViewModelView(viewModel, oldEyePos, oldEyeAngles, eyePos, eyeAngles)

			oldEyePos = position or oldEyePos
			eyeAngles = angles or eyeAngles
		end

		return oldEyePos, eyeAngles
	end
end