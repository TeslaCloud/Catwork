--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

--[[
	A lot of the code was taken from Gristwork, which was publicly released couple of years ago.
	Gristwork was made by Alex Grist.

	This library was almost rewritten by adding some methods that roleplaying framework "NutScript" uses.
	The latter can be found here:
	http://github.com/Chessnut/NutScript/
--]]

library.New("animation", cw)

local sequences = cw.animation.sequences or {}
cw.animation.sequences = sequences

local override = cw.animation.override or {}
cw.animation.override = override

local models = cw.animation.models or {}
cw.animation.models = models

local stored = cw.animation.stored or {}
cw.animation.stored = stored

stored.combineOverwatch = {
	normal = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_ANGRY},
		[ACT_MP_CROUCH_IDLE] = {ACT_CROUCHIDLE, ACT_CROUCHIDLE},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE, ACT_WALK_RIFLE},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_AIM_RIFLE, ACT_RUN_AIM_RIFLE},
		glide = ACT_GLIDE
	},
	pistol = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_CROUCHIDLE, ACT_CROUCHIDLE},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE, ACT_WALK_RIFLE},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_AIM_RIFLE, ACT_RUN_AIM_RIFLE}
	},
	smg = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_CROUCHIDLE, ACT_CROUCHIDLE},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE, ACT_WALK_AIM_RIFLE},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE, ACT_RUN_AIM_RIFLE}
	},
	shotgun = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SHOTGUN},
		[ACT_MP_CROUCH_IDLE] = {ACT_CROUCHIDLE, ACT_CROUCHIDLE},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE, ACT_WALK_AIM_SHOTGUN},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE, ACT_RUN_AIM_SHOTGUN}
	},
	grenade = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_ANGRY},
		[ACT_MP_CROUCH_IDLE] = {ACT_CROUCHIDLE, ACT_CROUCHIDLE},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE, ACT_WALK_RIFLE},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_AIM_RIFLE, ACT_RUN_AIM_RIFLE}
	},
	melee = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_ANGRY},
		[ACT_MP_CROUCH_IDLE] = {ACT_CROUCHIDLE, ACT_CROUCHIDLE},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE, ACT_WALK_RIFLE},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_AIM_RIFLE, ACT_RUN_AIM_RIFLE},
		attack = ACT_MELEE_ATTACK_SWING_GESTURE
	},
	rpg = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_RPG_RELAXED, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW_RPG, ACT_COVER_LOW_RPG},
		[ACT_MP_WALK] = {ACT_WALK_RPG_RELAXED, ACT_WALK_RPG},
		[ACT_MP_CROUCHWALK] = ACT_WALK_CROUCH_RPG,
		[ACT_MP_RUN] = {ACT_RUN_RPG_RELAXED, ACT_RUN_RPG},
		attack = ACT_RANGE_ATTACK_RPG
	},
}

stored.civilProtection = {
	normal = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_PISTOL_LOW, ACT_COVER_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_RIFLE},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN},
		glide = ACT_GLIDE
	},
	pistol = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_PISTOL, ACT_IDLE_ANGRY_PISTOL},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_PISTOL_LOW, ACT_COVER_PISTOL_LOW},
		[ACT_MP_WALK] = {ACT_WALK_PISTOL, ACT_WALK_AIM_PISTOL},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		[ACT_MP_RUN] = {ACT_RUN_PISTOL, ACT_RUN_AIM_PISTOL},
		attack = ACT_GESTURE_RANGE_ATTACK_PISTOL,
		reload = ACT_GESTURE_RELOAD_PISTOL
	},
	smg = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_SMG1_LOW, ACT_COVER_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE, ACT_WALK_AIM_RIFLE},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE, ACT_RUN_AIM_RIFLE}
	},
	shotgun = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_SMG1_LOW, ACT_COVER_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE, ACT_WALK_AIM_RIFLE},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE, ACT_RUN_AIM_RIFLE_STIMULATED}
	},
	grenade = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_ANGRY_MELEE},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_PISTOL_LOW, ACT_COVER_PISTOL_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_ANGRY},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN},
		attack = ACT_COMBINE_THROW_GRENADE
	},
	melee = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_ANGRY_MELEE},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_PISTOL_LOW, ACT_COVER_PISTOL_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_ANGRY},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN},
		attack = ACT_MELEE_ATTACK_SWING_GESTURE
	},
	vehicle = {
		prop_vehicle_airboat = {ACT_COVER_PISTOL_LOW, Vector(10, 0, 0)},
		prop_vehicle_jeep = {ACT_COVER_PISTOL_LOW, Vector(18, -2, 4)},
		prop_vehicle_prisoner_pod = {ACT_IDLE, Vector(-4, -0.5, 0)}
	}
}

stored.femaleCP = {
	normal = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_MANNEDGUN},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_COVER_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_RANGE_AIM_SMG1_LOW},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED},
		glide = ACT_GLIDE
	},
	pistol = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_PISTOL, ACT_IDLE_ANGRY_PISTOL},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_PISTOL},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		[ACT_MP_RUN] = {ACT_RUN_PISTOL, ACT_RUN_AIM_PISTOL},
		attack = ACT_GESTURE_RANGE_ATTACK_PISTOL,
		reload = ACT_GESTURE_RELOAD_PISTOL
	},
	smg = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_SMG1_LOW, ACT_COVER_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE, ACT_WALK_AIM_RIFLE},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE, ACT_RUN_AIM_RIFLE}
	},
	shotgun = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SHOTGUN_RELAXED, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_GESTURE_RANGE_ATTACK_SHOTGUN
	},
	grenade = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_MANNEDGUN},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_PISTOL},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN_AIM_PISTOL},
		attack = ACT_RANGE_ATTACK_THROW
	},
	melee = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_ANGRY_PISTOL},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_COVER_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_RIFLE},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN},
		attack = ACT_MELEE_ATTACK_SWING
	},
	vehicle = {
		prop_vehicle_airboat = {ACT_COVER_PISTOL_LOW, Vector(10, 0, 0)},
		prop_vehicle_jeep = {ACT_COVER_PISTOL_LOW, Vector(18, -2, 4)},
		prop_vehicle_prisoner_pod = {ACT_IDLE, Vector(-4, -0.5, 0)}
	}
}

stored.femaleHuman = {
	normal = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED},
		glide = ACT_GLIDE
	},
	pistol = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_PISTOL, ACT_IDLE_ANGRY_PISTOL},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_PISTOL},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN_AIM_PISTOL},
		attack = ACT_GESTURE_RANGE_ATTACK_PISTOL,
		reload = ACT_RELOAD_PISTOL
	},
	smg = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SMG1_RELAXED, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_GESTURE_RANGE_ATTACK_SMG1,
		reload = ACT_GESTURE_RELOAD_SMG1
	},
	shotgun = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SHOTGUN_RELAXED, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_GESTURE_RANGE_ATTACK_SHOTGUN
	},
	grenade = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_MANNEDGUN},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_PISTOL},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN_AIM_PISTOL},
		attack = ACT_RANGE_ATTACK_THROW
	},
	melee = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_PISTOL, ACT_IDLE_MANNEDGUN},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_COVER_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_RIFLE},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN},
		attack = ACT_MELEE_ATTACK_SWING
	},
	rpg = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_RPG_RELAXED, ACT_IDLE_ANGRY_RPG},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW_RPG, ACT_COVER_LOW_RPG},
		[ACT_MP_WALK] = {ACT_WALK_RPG_RELAXED, ACT_WALK_RPG},
		[ACT_MP_CROUCHWALK] = ACT_WALK_CROUCH_RPG,
		[ACT_MP_RUN] = {ACT_RUN_RPG_RELAXED, ACT_RUN_RPG},
		attack = ACT_RANGE_ATTACK_RPG
	},
	ar2 = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SHOTGUN_RELAXED, ACT_IDLE_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_AIM_AR2_LOW},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_GESTURE_RANGE_ATTACK_AR2,
		reload = ACT_GESTURE_RELOAD_SMG1
	},
	vehicle = {
		prop_vehicle_prisoner_pod = {"podpose", Vector(-3, 0, 0)},
		prop_vehicle_jeep = {"sitchair1", Vector(14, 0, -14)},
		prop_vehicle_airboat = {"sitchair1", Vector(8, 0, -20)}
	}
}

stored.maleHuman = {
	normal = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_COVER_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED},
		glide = ACT_GLIDE
	},
	pistol = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_RANGE_ATTACK_PISTOL},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_PISTOL_LOW, ACT_RANGE_AIM_PISTOL_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_GESTURE_RANGE_ATTACK_PISTOL,
		reload = ACT_RELOAD_PISTOL
	},
	smg = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SMG1_RELAXED, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_SMG1_LOW, ACT_RANGE_AIM_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_GESTURE_RANGE_ATTACK_SMG1,
		reload = ACT_GESTURE_RELOAD_SMG1
	},
	shotgun = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SHOTGUN_RELAXED, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_SMG1_LOW, ACT_RANGE_AIM_SMG1_LOW},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_GESTURE_RANGE_ATTACK_SHOTGUN
	},
	grenade = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE_MANNEDGUN},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_COVER_PISTOL_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN_RIFLE_STIMULATED},
		attack = ACT_RANGE_ATTACK_THROW
	},
	melee = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SUITCASE, ACT_IDLE_ANGRY_MELEE},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_COVER_LOW},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK_AIM_RIFLE},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN},
		attack = ACT_MELEE_ATTACK_SWING
	},
	rpg = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_RPG_RELAXED, ACT_IDLE_ANGRY_SMG1},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW_RPG, ACT_COVER_LOW_RPG},
		[ACT_MP_WALK] = {ACT_WALK_RPG_RELAXED, ACT_WALK_RPG},
		[ACT_MP_CROUCHWALK] = ACT_WALK_CROUCH_RPG,
		[ACT_MP_RUN] = {ACT_RUN_RPG_RELAXED, ACT_RUN_RPG},
		attack = ACT_RANGE_ATTACK_RPG
	},
	ar2 = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE_SHOTGUN_RELAXED, ACT_IDLE_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCH_IDLE] = {ACT_COVER_LOW, ACT_RANGE_AIM_AR2_LOW},
		[ACT_MP_WALK] = {ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED},
		[ACT_MP_CROUCHWALK] = {ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE},
		[ACT_MP_RUN] = {ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED},
		attack = ACT_GESTURE_RANGE_ATTACK_AR2,
		reload = ACT_GESTURE_RELOAD_SMG1
	},
	vehicle = stored.femaleHuman.vehicle
}

stored.vortigaunt = {
	normal = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, "actionidle"},
		[ACT_MP_CROUCH_IDLE] = {"crouchidle", "crouchidle"},
		[ACT_MP_WALK] = {ACT_WALK, "walk_all_holdgun"},
		[ACT_MP_CROUCHWALK] = {ACT_WALK, "walk_all_holdgun"},
		[ACT_MP_RUN] = {ACT_RUN, ACT_RUN},
		glide = ACT_GLIDE
	},
	pistol = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, "tcidle"},
		[ACT_MP_CROUCH_IDLE] = {"crouchidle", "crouchidle"},
		[ACT_MP_WALK] = {ACT_WALK, "walk_all_holdgun"},
		[ACT_MP_CROUCHWALK] = {ACT_WALK, "walk_all_holdgun"},
		[ACT_MP_RUN] = {ACT_RUN, "run_all_tc"}
	},
	smg = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, "tcidle"},
		[ACT_MP_CROUCH_IDLE] = {"crouchidle", "crouchidle"},
		[ACT_MP_WALK] = {ACT_WALK, "walk_all_holdgun"},
		[ACT_MP_CROUCHWALK] = {ACT_WALK, "walk_all_holdgun"},
		[ACT_MP_RUN] = {ACT_RUN, "run_all_tc"}
	},
	shotgun = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, "tcidle"},
		[ACT_MP_CROUCH_IDLE] = {"crouchidle", "crouchidle"},
		[ACT_MP_WALK] = {ACT_WALK, "walk_all_holdgun"},
		[ACT_MP_CROUCHWALK] = {ACT_WALK, "walk_all_holdgun"},
		[ACT_MP_RUN] = {ACT_RUN, "run_all_tc"}
	},
	grenade = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, "tcidle"},
		[ACT_MP_CROUCH_IDLE] = {"crouchidle", "crouchidle"},
		[ACT_MP_WALK] = {ACT_WALK, "walk_all_holdgun"},
		[ACT_MP_CROUCHWALK] = {ACT_WALK, "walk_all_holdgun"},
		[ACT_MP_RUN] = {ACT_RUN, "run_all_tc"}
	},
	melee = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, "tcidle"},
		[ACT_MP_CROUCH_IDLE] = {"crouchidle", "crouchidle"},
		[ACT_MP_WALK] = {ACT_WALK, "walk_all_holdgun"},
		[ACT_MP_CROUCHWALK] = {ACT_WALK, "walk_all_holdgun"},
		[ACT_MP_RUN] = {ACT_RUN, "run_all_tc"}
	}
}

-- A function to set a model's menu sequence.
function cw.animation:SetMenuSequence(model, sequence)
	sequences[string.lower(model)] = sequence
end

-- A function to get a model's menu sequence.
function cw.animation:GetMenuSequence(model, bRandom)
	local sequence = sequences[model:lower()]

	if (sequence) then
		if (type(sequence) == "table") then
			if (bRandom) then
				return sequence[math.random(1, #sequence)]
			else
				return sequence
			end
		else
			return sequence
		end
	end
end

-- A function to add a model.
function cw.animation:AddModel(class, model)
	local lowerModel = string.lower(model)
		models[lowerModel] = class
	return lowerModel
end

-- A function to add an override.
function cw.animation:AddOverride(model, key, value)
	local lowerModel = string.lower(model)

	if (!override[lowerModel]) then
		override[lowerModel] = {}
	end

	override[lowerModel][key] = value
end

-- A function to get an animation for a model.
function cw.animation:GetForModel(model, holdType, key, bNoFallbacks)
	if (!model) then
		debug.Trace()
		return
	end

	local lowerModel = string.lower(model)
	local animTable = self:GetTable(lowerModel)
	local overrideTable = override[lowerModel]

	if (!bNoFallbacks) then
		if (!animTable[holdType]) then
			holdType = "normal"
		end

		if (!animTable[holdType][key]) then
			key = ACT_MP_STAND_IDLE
		end
	end

	local finalAnimation = animTable[holdType][key]

	if (overrideTable and overrideTable[holdType] and overrideTable[holdType][key]) then
		finalAnimation = overrideTable[holdType][key]
	end

	return finalAnimation
end

-- A function to get a model's class.
function cw.animation:GetModelClass(model, alwaysReal)
	local modelClass = models[string.lower(model)]

	if (!modelClass) then
		if (!alwaysReal) then
			return "maleHuman"
		end
	else
		return modelClass
	end
end

-- A function to add a vortigaunt model.
function cw.animation:AddVortigauntModel(model)
	return self:AddModel("vortigaunt", model)
end

-- A function to add a Combine Overwatch model.
function cw.animation:AddCombineOverwatchModel(model)
	return self:AddModel("combineOverwatch", model)
end

-- A function to add a Civil Protection model.
function cw.animation:AddCivilProtectionModel(model)
	return self:AddModel("civilProtection", model)
end

-- A function to add a Civil Protection model.
function cw.animation:AddFemaleCivilProtectionModel(model)
	return self:AddModel("femaleCP", model)
end

-- A function to add a female human model.
function cw.animation:AddFemaleHumanModel(model)
	return self:AddModel("femaleHuman", model)
end

-- A function to add a male human model.
function cw.animation:AddMaleHumanModel(model)
	return self:AddModel("maleHuman", model)
end

do
	local translateHoldTypes = {
		[""] = "normal",
		["physgun"] = "smg",
		["ar2"] = "smg",
		["crossbow"] = "shotgun",
		["rpg"] = "shotgun",
		["slam"] = "normal",
		["grenade"] = "normal",
		["fist"] = "normal",
		["melee2"] = "melee",
		["passive"] = "normal",
		["knife"] = "melee",
		["revolver"] = "pistol"
	}

	local weaponHoldTypes = {
		["weapon_ar2"] = "smg",
		["weapon_smg1"] = "smg",
		["weapon_physgun"] = "smg",
		["weapon_crossbow"] = "smg",
		["weapon_physcannon"] = "smg",
		["weapon_crowbar"] = "melee",
		["weapon_bugbait"] = "melee",
		["weapon_stunstick"] = "melee",
		["gmod_tool"] = "pistol",
		["weapon_357"] = "pistol",
		["weapon_pistol"] = "pistol",
		["weapon_frag"] = "grenade",
		["weapon_slam"] = "grenade",
		["weapon_rpg"] = "shotgun",
		["weapon_shotgun"] = "shotgun",
		["weapon_annabelle"] = "shotgun",
		["sxbase_m9"] = "pistol",
		["sxbase_ar2"] = "smg",
		["sxbase_ar21"] = "smg",
		["sxbase_mp7"] = "smg",
		["sxbase_m40a1"] = "smg",
		["sxbase_spas12"] = "smg",
		["sxbase_ak74"] = "smg",
		["sxbase_uspmatch"] = "pistol",
		["sxbase_stunstick"] = "melee",
		["sxbase_crowbar"] = "melee",
		["sxbase_fireaxe"] = "melee",
		["sxbase_he"] = "grenade",
		["sxbase_sg"] = "grenade",
		["sxbase_fg"] = "grenade",
		["grub_combine_sniper"] = "smg",
		["sxbase_m9_2"] = "pistol",
		["sxbase_ak74n_2"] = "smg",
		["sxbase_ak74n"] = "smg",
		["sxbase_m40a1_2"] = "smg",
		["sxbase_m40a1optic_2"] = "smg",
		["sxbase_m40a1optic"] = "smg",
		["sxbase_mp7_s"] = "smg",
		["sxbase_mp7_ls"] = "smg",
		["sxbase_mp7_s_ls"] = "smg",
		["sxbase_mp7_bsk_ls"] = "smg",
		["sxbase_mp7_s_bsk_ls"] = "smg",
		["sxbase_mp7_micro_ls"] = "smg",
		["sxbase_mp7_s_micro_ls"] = "smg",
	}

	-- A function to get a weapon's hold type.
	function cw.animation:GetWeaponHoldType(player, weapon)
		local class = string.lower(weapon:GetClass())
		local holdType = "normal"

		if (weaponHoldTypes[class]) then
			holdType = weaponHoldTypes[class]
		elseif (weapon and weapon.HoldType) then
			if (translateHoldTypes[weapon.HoldType]) then
				holdType = translateHoldTypes[weapon.HoldType]
			else
				holdType = weapon.HoldType
			end
		end

		return string.lower(holdType)
	end
end

-- A function to get an animation table.
function cw.animation:GetTable(model)
	local lowerModel = string.lower(model)

 	if (string.find(model, "/player/")) then
 		return nil	
 	end

	local class = models[lowerModel]

	if (class and stored[class]) then
		return stored[class]
	elseif (string.find(lowerModel, "female")) then
		return stored.femaleHuman
	else
		return stored.maleHuman
	end
end

local handsModels = {}
local blackModels = {}

-- A function to add viewmodel c_arms info to a model.
function cw.animation:AddHandsModel(model, hands)
	handsModels[string.lower(model)] = hands
end

-- A function to make a model use the black skin for hands viewmodels.
function cw.animation:AddBlackModel(model)
	blackModels[string.lower(model)] = true
end

-- A function to make a model use the zombie skin for citizen hands.
function cw.animation:AddZombieHands(model)
	self:AddHandsModel(model, {
		body = 0000000,
		model = "models/weapons/c_arms_citizen.mdl",
		skin = 2
	})
end

-- A function to make a model use the HL2 HEV viewmodel hands.
function cw.animation:AddHEVHands(model)
	self:AddHandsModel(model, {
		body = 0000000,
		model = "models/weapons/c_arms_hev.mdl",
		skin = 0
	})
end

-- A function to make a model use the combine viewmodel hands.
function cw.animation:AddCombineHands(model)
	self:AddHandsModel(model, {
		body = 0000000,
		model = "models/weapons/c_arms_combine.mdl",
		skin = 0
	})
end

-- A function to make a model use the CSS viewmodel hands.
function cw.animation:AddCSSHands(model)
	self:AddHandsModel(model, {
		body = 0000000,
		model = "models/weapons/c_arms_cstrike.mdl",
		skin = 0
	})
end

-- A function to make a model use the refugee viewmodel hands.
function cw.animation:AddRefugeeHands(model)
	self:AddHandsModel(model, {
		body = 01,
		model = "models/weapons/c_arms_refugee.mdl",
		skin = 0
	})
end

-- a function to make a model use the refugee viewmodel hands with a zombie skin.
function cw.animation:AddZombieRefugeeHands(model)
	self:AddHandsModel(model, {
		body = 0000000,
		model = "models/weapons/c_arms_refugee.mdl",
		skin = 2
	})
end

-- A function to check for stored hands info by model.
function cw.animation:CheckHands(model, animTable)
	local info = {
		body = 0000000,
		model = "models/weapons/c_arms_citizen.mdl",
		skin = 0
	}

	if (animTable and animTable.hands) then
		info = animTable.hands
	end

	for k, v in pairs(handsModels) do
		if (string.find(model, k)) then
			info = v

			break
		end
	end

	self:AdjustHandsInfo(model, info)

	return info
end

-- A function to adjust the hands info with checks for if a model is set to use the black skin.
function cw.animation:AdjustHandsInfo(model, info)
	if (info.model == "models/weapons/c_arms_citizen.mdl" or info.model == "models/weapons/c_arms_refugee.mdl") then
		for k, v in pairs(blackModels) do
			if (string.find(model, k)) then
				info.skin = 1

				break
			elseif (info.skin == 1) then
				info.skin = 0
			end
		end
	end

	hook.Run("AdjustCModelHandsInfo", model, info)
end

-- A function to get the c_model hands based on model.
function cw.animation:GetHandsInfo(model)
	local animTable = self:GetTable(model)

	return self:CheckHands(string.lower(model), animTable)
end

cw.animation:AddBlackModel("/male_01.mdl")
cw.animation:AddBlackModel("/male_03.mdl")
cw.animation:AddBlackModel("/female_03.mdl")

cw.animation:AddRefugeeHands("/group03/")
cw.animation:AddRefugeeHands("/group03m/")

cw.animation:AddZombieRefugeeHands("/Zombie/")

cw.animation:AddVortigauntModel("models/vortigaunt.mdl")
cw.animation:AddVortigauntModel("models/vortigaunt_slave.mdl")
cw.animation:AddVortigauntModel("models/vortigaunt_doctor.mdl")

cw.animation:AddCombineOverwatchModel("models/combine_soldier_prisonguard.mdl")
cw.animation:AddCombineOverwatchModel("models/combine_super_soldier.mdl")
cw.animation:AddCombineOverwatchModel("models/combine_soldier.mdl")

cw.animation:AddCivilProtectionModel("models/police.mdl");
