--- Defines the `cw.animation` library, which assigns player models to animation classes and picks the animation for
-- each activity and weapon hold type.
--
-- It holds the animation tables for the Combine Overwatch, Civil Protection, male and female human and vortigaunt
-- classes, and lets schemas assign models to a class or override single animations. It also decides which viewmodel
-- hands a model uses.

--[[
  A lot of the code was taken from Gristwork, which was publicly released couple of years ago.
  Gristwork was made by Alex Grist.

  This library was almost rewritten by adding some methods that roleplaying framework "NutScript" uses.
  The latter can be found here:
  http://github.com/Chessnut/NutScript/
--]]

library.New('animation', cw)

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
    [ACT_MP_STAND_IDLE] = { ACT_IDLE, ACT_IDLE_ANGRY },
    [ACT_MP_CROUCH_IDLE] = { ACT_CROUCHIDLE, ACT_CROUCHIDLE },
    [ACT_MP_WALK] = { ACT_WALK_RIFLE, ACT_WALK_RIFLE },
    [ACT_MP_CROUCHWALK] = { ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE },
    [ACT_MP_RUN] = { ACT_RUN_AIM_RIFLE, ACT_RUN_AIM_RIFLE },
    glide = ACT_GLIDE
  },
  pistol = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE, ACT_IDLE_ANGRY_SMG1 },
    [ACT_MP_CROUCH_IDLE] = { ACT_CROUCHIDLE, ACT_CROUCHIDLE },
    [ACT_MP_WALK] = { ACT_WALK_RIFLE, ACT_WALK_RIFLE },
    [ACT_MP_CROUCHWALK] = { ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE },
    [ACT_MP_RUN] = { ACT_RUN_AIM_RIFLE, ACT_RUN_AIM_RIFLE }
  },
  smg = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SMG1 },
    [ACT_MP_CROUCH_IDLE] = { ACT_CROUCHIDLE, ACT_CROUCHIDLE },
    [ACT_MP_WALK] = { ACT_WALK_RIFLE, ACT_WALK_AIM_RIFLE },
    [ACT_MP_CROUCHWALK] = { ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE },
    [ACT_MP_RUN] = { ACT_RUN_RIFLE, ACT_RUN_AIM_RIFLE }
  },
  shotgun = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SHOTGUN },
    [ACT_MP_CROUCH_IDLE] = { ACT_CROUCHIDLE, ACT_CROUCHIDLE },
    [ACT_MP_WALK] = { ACT_WALK_RIFLE, ACT_WALK_AIM_SHOTGUN },
    [ACT_MP_CROUCHWALK] = { ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE },
    [ACT_MP_RUN] = { ACT_RUN_RIFLE, ACT_RUN_AIM_SHOTGUN }
  },
  grenade = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE, ACT_IDLE_ANGRY },
    [ACT_MP_CROUCH_IDLE] = { ACT_CROUCHIDLE, ACT_CROUCHIDLE },
    [ACT_MP_WALK] = { ACT_WALK_RIFLE, ACT_WALK_RIFLE },
    [ACT_MP_CROUCHWALK] = { ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE },
    [ACT_MP_RUN] = { ACT_RUN_AIM_RIFLE, ACT_RUN_AIM_RIFLE }
  },
  melee = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE, ACT_IDLE_ANGRY },
    [ACT_MP_CROUCH_IDLE] = { ACT_CROUCHIDLE, ACT_CROUCHIDLE },
    [ACT_MP_WALK] = { ACT_WALK_RIFLE, ACT_WALK_RIFLE },
    [ACT_MP_CROUCHWALK] = { ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE },
    [ACT_MP_RUN] = { ACT_RUN_AIM_RIFLE, ACT_RUN_AIM_RIFLE },
    attack = ACT_MELEE_ATTACK_SWING_GESTURE
  },
  rpg = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE_RPG_RELAXED, ACT_IDLE_ANGRY_SMG1 },
    [ACT_MP_CROUCH_IDLE] = { ACT_COVER_LOW_RPG, ACT_COVER_LOW_RPG },
    [ACT_MP_WALK] = { ACT_WALK_RPG_RELAXED, ACT_WALK_RPG },
    [ACT_MP_CROUCHWALK] = ACT_WALK_CROUCH_RPG,
    [ACT_MP_RUN] = { ACT_RUN_RPG_RELAXED, ACT_RUN_RPG },
    attack = ACT_RANGE_ATTACK_RPG
  }
}

stored.civilProtection = {
  normal = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE, ACT_IDLE_ANGRY_SMG1 },
    [ACT_MP_CROUCH_IDLE] = { ACT_COVER_PISTOL_LOW, ACT_COVER_SMG1_LOW },
    [ACT_MP_WALK] = { ACT_WALK, ACT_WALK_AIM_RIFLE },
    [ACT_MP_CROUCHWALK] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH },
    [ACT_MP_RUN] = { ACT_RUN, ACT_RUN },
    glide = ACT_GLIDE
  },
  pistol = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE_PISTOL, ACT_IDLE_ANGRY_PISTOL },
    [ACT_MP_CROUCH_IDLE] = { ACT_COVER_PISTOL_LOW, ACT_COVER_PISTOL_LOW },
    [ACT_MP_WALK] = { ACT_WALK_PISTOL, ACT_WALK_AIM_PISTOL },
    [ACT_MP_CROUCHWALK] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH },
    [ACT_MP_RUN] = { ACT_RUN_PISTOL, ACT_RUN_AIM_PISTOL },
    attack = ACT_GESTURE_RANGE_ATTACK_PISTOL,
    reload = ACT_GESTURE_RELOAD_PISTOL
  },
  smg = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SMG1 },
    [ACT_MP_CROUCH_IDLE] = { ACT_COVER_SMG1_LOW, ACT_COVER_SMG1_LOW },
    [ACT_MP_WALK] = { ACT_WALK_RIFLE, ACT_WALK_AIM_RIFLE },
    [ACT_MP_CROUCHWALK] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH },
    [ACT_MP_RUN] = { ACT_RUN_RIFLE, ACT_RUN_AIM_RIFLE }
  },
  shotgun = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SMG1 },
    [ACT_MP_CROUCH_IDLE] = { ACT_COVER_SMG1_LOW, ACT_COVER_SMG1_LOW },
    [ACT_MP_WALK] = { ACT_WALK_RIFLE, ACT_WALK_AIM_RIFLE },
    [ACT_MP_CROUCHWALK] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH },
    [ACT_MP_RUN] = { ACT_RUN_RIFLE, ACT_RUN_AIM_RIFLE_STIMULATED }
  },
  grenade = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE, ACT_IDLE_ANGRY_MELEE },
    [ACT_MP_CROUCH_IDLE] = { ACT_COVER_PISTOL_LOW, ACT_COVER_PISTOL_LOW },
    [ACT_MP_WALK] = { ACT_WALK, ACT_WALK_ANGRY },
    [ACT_MP_CROUCHWALK] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH },
    [ACT_MP_RUN] = { ACT_RUN, ACT_RUN },
    attack = ACT_COMBINE_THROW_GRENADE
  },
  melee = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE, ACT_IDLE_ANGRY_MELEE },
    [ACT_MP_CROUCH_IDLE] = { ACT_COVER_PISTOL_LOW, ACT_COVER_PISTOL_LOW },
    [ACT_MP_WALK] = { ACT_WALK, ACT_WALK_ANGRY },
    [ACT_MP_CROUCHWALK] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH },
    [ACT_MP_RUN] = { ACT_RUN, ACT_RUN },
    attack = ACT_MELEE_ATTACK_SWING_GESTURE
  },
  vehicle = {
    prop_vehicle_airboat = { ACT_COVER_PISTOL_LOW, Vector(10, 0, 0) },
    prop_vehicle_jeep = { ACT_COVER_PISTOL_LOW, Vector(18, -2, 4) },
    prop_vehicle_prisoner_pod = { ACT_IDLE, Vector(-4, -0.5, 0) }
  }
}

stored.femaleCP = {
  normal = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE, ACT_IDLE_MANNEDGUN },
    [ACT_MP_CROUCH_IDLE] = { ACT_COVER_LOW, ACT_COVER_LOW },
    [ACT_MP_WALK] = { ACT_WALK, ACT_RANGE_AIM_SMG1_LOW },
    [ACT_MP_CROUCHWALK] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE },
    [ACT_MP_RUN] = { ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED },
    glide = ACT_GLIDE
  },
  pistol = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE_PISTOL, ACT_IDLE_ANGRY_PISTOL },
    [ACT_MP_CROUCH_IDLE] = { ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW },
    [ACT_MP_WALK] = { ACT_WALK, ACT_WALK_AIM_PISTOL },
    [ACT_MP_CROUCHWALK] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH },
    [ACT_MP_RUN] = { ACT_RUN_PISTOL, ACT_RUN_AIM_PISTOL },
    attack = ACT_GESTURE_RANGE_ATTACK_PISTOL,
    reload = ACT_GESTURE_RELOAD_PISTOL
  },
  smg = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE_SMG1, ACT_IDLE_ANGRY_SMG1 },
    [ACT_MP_CROUCH_IDLE] = { ACT_COVER_SMG1_LOW, ACT_COVER_SMG1_LOW },
    [ACT_MP_WALK] = { ACT_WALK_RIFLE, ACT_WALK_AIM_RIFLE },
    [ACT_MP_CROUCHWALK] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH },
    [ACT_MP_RUN] = { ACT_RUN_RIFLE, ACT_RUN_AIM_RIFLE }
  },
  shotgun = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE_SHOTGUN_RELAXED, ACT_IDLE_ANGRY_SMG1 },
    [ACT_MP_CROUCH_IDLE] = { ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW },
    [ACT_MP_WALK] = { ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED },
    [ACT_MP_CROUCHWALK] = { ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_AIM_RIFLE },
    [ACT_MP_RUN] = { ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED },
    attack = ACT_GESTURE_RANGE_ATTACK_SHOTGUN
  },
  grenade = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE, ACT_IDLE_MANNEDGUN },
    [ACT_MP_CROUCH_IDLE] = { ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW },
    [ACT_MP_WALK] = { ACT_WALK, ACT_WALK_AIM_PISTOL },
    [ACT_MP_CROUCHWALK] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE },
    [ACT_MP_RUN] = { ACT_RUN, ACT_RUN_AIM_PISTOL },
    attack = ACT_RANGE_ATTACK_THROW
  },
  melee = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE, ACT_IDLE_ANGRY_PISTOL },
    [ACT_MP_CROUCH_IDLE] = { ACT_COVER_LOW, ACT_COVER_LOW },
    [ACT_MP_WALK] = { ACT_WALK, ACT_WALK_AIM_RIFLE },
    [ACT_MP_CROUCHWALK] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH },
    [ACT_MP_RUN] = { ACT_RUN, ACT_RUN },
    attack = ACT_MELEE_ATTACK_SWING
  },
  vehicle = {
    prop_vehicle_airboat = { ACT_COVER_PISTOL_LOW, Vector(10, 0, 0) },
    prop_vehicle_jeep = { ACT_COVER_PISTOL_LOW, Vector(18, -2, 4) },
    prop_vehicle_prisoner_pod = { ACT_IDLE, Vector(-4, -0.5, 0) }
  }
}

stored.femaleHuman = {
  normal = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE, ACT_IDLE_ANGRY_SMG1 },
    [ACT_MP_CROUCH_IDLE] = { ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW },
    [ACT_MP_WALK] = { ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED },
    [ACT_MP_CROUCHWALK] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE },
    [ACT_MP_RUN] = { ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED },
    glide = ACT_GLIDE
  },
  pistol = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE_PISTOL, ACT_IDLE_ANGRY_PISTOL },
    [ACT_MP_CROUCH_IDLE] = { ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW },
    [ACT_MP_WALK] = { ACT_WALK, ACT_WALK_AIM_PISTOL },
    [ACT_MP_CROUCHWALK] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE },
    [ACT_MP_RUN] = { ACT_RUN, ACT_RUN_AIM_PISTOL },
    attack = ACT_GESTURE_RANGE_ATTACK_PISTOL,
    reload = ACT_RELOAD_PISTOL
  },
  smg = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE_SMG1_RELAXED, ACT_IDLE_ANGRY_SMG1 },
    [ACT_MP_CROUCH_IDLE] = { ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW },
    [ACT_MP_WALK] = { ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED },
    [ACT_MP_CROUCHWALK] = { ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_AIM_RIFLE },
    [ACT_MP_RUN] = { ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED },
    attack = ACT_GESTURE_RANGE_ATTACK_SMG1,
    reload = ACT_GESTURE_RELOAD_SMG1
  },
  shotgun = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE_SHOTGUN_RELAXED, ACT_IDLE_ANGRY_SMG1 },
    [ACT_MP_CROUCH_IDLE] = { ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW },
    [ACT_MP_WALK] = { ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED },
    [ACT_MP_CROUCHWALK] = { ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_AIM_RIFLE },
    [ACT_MP_RUN] = { ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED },
    attack = ACT_GESTURE_RANGE_ATTACK_SHOTGUN
  },
  grenade = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE, ACT_IDLE_MANNEDGUN },
    [ACT_MP_CROUCH_IDLE] = { ACT_COVER_LOW, ACT_RANGE_AIM_SMG1_LOW },
    [ACT_MP_WALK] = { ACT_WALK, ACT_WALK_AIM_PISTOL },
    [ACT_MP_CROUCHWALK] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE },
    [ACT_MP_RUN] = { ACT_RUN, ACT_RUN_AIM_PISTOL },
    attack = ACT_RANGE_ATTACK_THROW
  },
  melee = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE_PISTOL, ACT_IDLE_MANNEDGUN },
    [ACT_MP_CROUCH_IDLE] = { ACT_COVER_LOW, ACT_COVER_LOW },
    [ACT_MP_WALK] = { ACT_WALK, ACT_WALK_AIM_RIFLE },
    [ACT_MP_CROUCHWALK] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH },
    [ACT_MP_RUN] = { ACT_RUN, ACT_RUN },
    attack = ACT_MELEE_ATTACK_SWING
  },
  rpg = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE_RPG_RELAXED, ACT_IDLE_ANGRY_RPG },
    [ACT_MP_CROUCH_IDLE] = { ACT_COVER_LOW_RPG, ACT_COVER_LOW_RPG },
    [ACT_MP_WALK] = { ACT_WALK_RPG_RELAXED, ACT_WALK_RPG },
    [ACT_MP_CROUCHWALK] = ACT_WALK_CROUCH_RPG,
    [ACT_MP_RUN] = { ACT_RUN_RPG_RELAXED, ACT_RUN_RPG },
    attack = ACT_RANGE_ATTACK_RPG
  },
  ar2 = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE_SHOTGUN_RELAXED, ACT_IDLE_AIM_RIFLE_STIMULATED },
    [ACT_MP_CROUCH_IDLE] = { ACT_COVER_LOW, ACT_RANGE_AIM_AR2_LOW },
    [ACT_MP_WALK] = { ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED },
    [ACT_MP_CROUCHWALK] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE },
    [ACT_MP_RUN] = { ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED },
    attack = ACT_GESTURE_RANGE_ATTACK_AR2,
    reload = ACT_GESTURE_RELOAD_SMG1
  },
  vehicle = {
    prop_vehicle_prisoner_pod = { 'podpose', Vector(-3, 0, 0) },
    prop_vehicle_jeep = { 'sitchair1', Vector(14, 0, -14) },
    prop_vehicle_airboat = { 'sitchair1', Vector(8, 0, -20) }
  }
}

stored.maleHuman = {
  normal = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE, ACT_IDLE_ANGRY_SMG1 },
    [ACT_MP_CROUCH_IDLE] = { ACT_COVER_LOW, ACT_COVER_LOW },
    [ACT_MP_WALK] = { ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED },
    [ACT_MP_CROUCHWALK] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE },
    [ACT_MP_RUN] = { ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED },
    glide = ACT_GLIDE
  },
  pistol = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE, ACT_RANGE_ATTACK_PISTOL },
    [ACT_MP_CROUCH_IDLE] = { ACT_COVER_PISTOL_LOW, ACT_RANGE_AIM_PISTOL_LOW },
    [ACT_MP_WALK] = { ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED },
    [ACT_MP_CROUCHWALK] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE },
    [ACT_MP_RUN] = { ACT_RUN, ACT_RUN_AIM_RIFLE_STIMULATED },
    attack = ACT_GESTURE_RANGE_ATTACK_PISTOL,
    reload = ACT_RELOAD_PISTOL
  },
  smg = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE_SMG1_RELAXED, ACT_IDLE_ANGRY_SMG1 },
    [ACT_MP_CROUCH_IDLE] = { ACT_COVER_SMG1_LOW, ACT_RANGE_AIM_SMG1_LOW },
    [ACT_MP_WALK] = { ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED },
    [ACT_MP_CROUCHWALK] = { ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_AIM_RIFLE },
    [ACT_MP_RUN] = { ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED },
    attack = ACT_GESTURE_RANGE_ATTACK_SMG1,
    reload = ACT_GESTURE_RELOAD_SMG1
  },
  shotgun = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE_SHOTGUN_RELAXED, ACT_IDLE_ANGRY_SMG1 },
    [ACT_MP_CROUCH_IDLE] = { ACT_COVER_SMG1_LOW, ACT_RANGE_AIM_SMG1_LOW },
    [ACT_MP_WALK] = { ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED },
    [ACT_MP_CROUCHWALK] = { ACT_WALK_CROUCH_RIFLE, ACT_WALK_CROUCH_RIFLE },
    [ACT_MP_RUN] = { ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED },
    attack = ACT_GESTURE_RANGE_ATTACK_SHOTGUN
  },
  grenade = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE, ACT_IDLE_MANNEDGUN },
    [ACT_MP_CROUCH_IDLE] = { ACT_COVER_LOW, ACT_COVER_PISTOL_LOW },
    [ACT_MP_WALK] = { ACT_WALK, ACT_WALK_AIM_RIFLE_STIMULATED },
    [ACT_MP_CROUCHWALK] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE },
    [ACT_MP_RUN] = { ACT_RUN, ACT_RUN_RIFLE_STIMULATED },
    attack = ACT_RANGE_ATTACK_THROW
  },
  melee = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE_SUITCASE, ACT_IDLE_ANGRY_MELEE },
    [ACT_MP_CROUCH_IDLE] = { ACT_COVER_LOW, ACT_COVER_LOW },
    [ACT_MP_WALK] = { ACT_WALK, ACT_WALK_AIM_RIFLE },
    [ACT_MP_CROUCHWALK] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH },
    [ACT_MP_RUN] = { ACT_RUN, ACT_RUN },
    attack = ACT_MELEE_ATTACK_SWING
  },
  rpg = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE_RPG_RELAXED, ACT_IDLE_ANGRY_SMG1 },
    [ACT_MP_CROUCH_IDLE] = { ACT_COVER_LOW_RPG, ACT_COVER_LOW_RPG },
    [ACT_MP_WALK] = { ACT_WALK_RPG_RELAXED, ACT_WALK_RPG },
    [ACT_MP_CROUCHWALK] = ACT_WALK_CROUCH_RPG,
    [ACT_MP_RUN] = { ACT_RUN_RPG_RELAXED, ACT_RUN_RPG },
    attack = ACT_RANGE_ATTACK_RPG
  },
  ar2 = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE_SHOTGUN_RELAXED, ACT_IDLE_AIM_RIFLE_STIMULATED },
    [ACT_MP_CROUCH_IDLE] = { ACT_COVER_LOW, ACT_RANGE_AIM_AR2_LOW },
    [ACT_MP_WALK] = { ACT_WALK_RIFLE_RELAXED, ACT_WALK_AIM_RIFLE_STIMULATED },
    [ACT_MP_CROUCHWALK] = { ACT_WALK_CROUCH, ACT_WALK_CROUCH_AIM_RIFLE },
    [ACT_MP_RUN] = { ACT_RUN_RIFLE_RELAXED, ACT_RUN_AIM_RIFLE_STIMULATED },
    attack = ACT_GESTURE_RANGE_ATTACK_AR2,
    reload = ACT_GESTURE_RELOAD_SMG1
  },
  vehicle = stored.femaleHuman.vehicle
}

stored.vortigaunt = {
  normal = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE, 'actionidle' },
    [ACT_MP_CROUCH_IDLE] = { 'crouchidle', 'crouchidle' },
    [ACT_MP_WALK] = { ACT_WALK, 'walk_all_holdgun' },
    [ACT_MP_CROUCHWALK] = { ACT_WALK, 'walk_all_holdgun' },
    [ACT_MP_RUN] = { ACT_RUN, ACT_RUN },
    glide = ACT_GLIDE
  },
  pistol = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE, 'tcidle' },
    [ACT_MP_CROUCH_IDLE] = { 'crouchidle', 'crouchidle' },
    [ACT_MP_WALK] = { ACT_WALK, 'walk_all_holdgun' },
    [ACT_MP_CROUCHWALK] = { ACT_WALK, 'walk_all_holdgun' },
    [ACT_MP_RUN] = { ACT_RUN, 'run_all_tc' }
  },
  smg = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE, 'tcidle' },
    [ACT_MP_CROUCH_IDLE] = { 'crouchidle', 'crouchidle' },
    [ACT_MP_WALK] = { ACT_WALK, 'walk_all_holdgun' },
    [ACT_MP_CROUCHWALK] = { ACT_WALK, 'walk_all_holdgun' },
    [ACT_MP_RUN] = { ACT_RUN, 'run_all_tc' }
  },
  shotgun = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE, 'tcidle' },
    [ACT_MP_CROUCH_IDLE] = { 'crouchidle', 'crouchidle' },
    [ACT_MP_WALK] = { ACT_WALK, 'walk_all_holdgun' },
    [ACT_MP_CROUCHWALK] = { ACT_WALK, 'walk_all_holdgun' },
    [ACT_MP_RUN] = { ACT_RUN, 'run_all_tc' }
  },
  grenade = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE, 'tcidle' },
    [ACT_MP_CROUCH_IDLE] = { 'crouchidle', 'crouchidle' },
    [ACT_MP_WALK] = { ACT_WALK, 'walk_all_holdgun' },
    [ACT_MP_CROUCHWALK] = { ACT_WALK, 'walk_all_holdgun' },
    [ACT_MP_RUN] = { ACT_RUN, 'run_all_tc' }
  },
  melee = {
    [ACT_MP_STAND_IDLE] = { ACT_IDLE, 'tcidle' },
    [ACT_MP_CROUCH_IDLE] = { 'crouchidle', 'crouchidle' },
    [ACT_MP_WALK] = { ACT_WALK, 'walk_all_holdgun' },
    [ACT_MP_CROUCHWALK] = { ACT_WALK, 'walk_all_holdgun' },
    [ACT_MP_RUN] = { ACT_RUN, 'run_all_tc' }
  }
}

--- Sets the sequence a model plays in the character menu.
--
-- @param model [String Model path; case is ignored]
-- @param sequence [Any Sequence name, or a List of sequence names to pick from at random]
-- @see cw.animation:GetMenuSequence
function cw.animation:SetMenuSequence(model, sequence)
  sequences[string.lower(model)] = sequence
end

--- Returns the sequence a model plays in the character menu.
--
-- @param model [String Model path; case is ignored]
-- @param bRandom=nil [Boolean Pick one sequence at random when a list is stored]
-- @return [Any The sequence name, the stored List when `bRandom` is not set, or `nil` if none is
-- set]
-- @see cw.animation:SetMenuSequence
function cw.animation:GetMenuSequence(model, bRandom)
  local sequence = sequences[model:lower()]

  if sequence then
    if type(sequence) == 'table' then
      if bRandom then
        return sequence[math.random(1, #sequence)]
      else
        return sequence
      end
    else
      return sequence
    end
  end
end

--- Assigns a model to an animation class.
--
-- @param class [String Animation class, a key of `cw.animation.stored` such as `'maleHuman'` or
-- `'civilProtection'`]
-- @param model [String Model path; case is ignored]
-- @return [String The lowercased model path]
function cw.animation:AddModel(class, model)
  local lowerModel = string.lower(model)
    models[lowerModel] = class
  return lowerModel
end

--- Overrides a model's animations for one hold type.
--
-- Overrides are checked by `cw.animation:GetForModel` before the model's animation class.
--
-- @param model [String Model path; case is ignored]
-- @param key [String Hold type to override, such as `'pistol'`]
-- @param value [Map Animations keyed by activity (`ACT_MP_*`) or by `'attack'`/`'reload'`]
function cw.animation:AddOverride(model, key, value)
  local lowerModel = string.lower(model)

  if !override[lowerModel] then
    override[lowerModel] = {}
  end

  override[lowerModel][key] = value
end

--- Returns the animation a model uses for an activity and hold type.
--
-- Unknown hold types fall back to `normal` and unknown activities to `ACT_MP_STAND_IDLE`, unless
-- `bNoFallbacks` is set. Overrides from `cw.animation:AddOverride` take precedence. Returns nothing
-- for models without an animation table, and prints a stack trace when `model` is `nil`.
--
-- ```
-- local attackAnimation = cw.animation:GetForModel(model, weaponHoldType, 'attack', true)
-- ```
--
-- @param model [String Model path]
-- @param holdType [String Hold type, such as `'normal'` or `'smg'`]
-- @param key [Any Activity (`ACT_MP_*`), or `'attack'`, `'reload'` or `'glide'`]
-- @param bNoFallbacks=nil [Boolean Return `nil` instead of falling back]
-- @return [Any The animation: an activity Number, a sequence String, or a List of two of these
-- for the lowered and raised states]
function cw.animation:GetForModel(model, holdType, key, bNoFallbacks)
  if !model then
    debug.Trace()
    return
  end

  local lowerModel = string.lower(model)
  local animTable = self:GetTable(lowerModel)
  local overrideTable = override[lowerModel]

  if !animTable then return end

  if !bNoFallbacks then
    if !animTable[holdType] then
      holdType = 'normal'
    end

    if animTable[holdType] and !animTable[holdType][key] then
      key = ACT_MP_STAND_IDLE
    end
  end

  local finalAnimation = animTable[holdType] and animTable[holdType][key]

  if overrideTable and overrideTable[holdType] and overrideTable[holdType][key] then
    finalAnimation = overrideTable[holdType][key]
  end

  return finalAnimation
end

--- Returns the animation class a model was assigned with `cw.animation:AddModel`.
--
-- @param model [String Model path; case is ignored]
-- @param alwaysReal=nil [Boolean Return `nil` instead of `'maleHuman'` for unassigned models]
-- @return [String The animation class]
function cw.animation:GetModelClass(model, alwaysReal)
  local modelClass = models[string.lower(model)]

  if !modelClass then
    if !alwaysReal then
      return 'maleHuman'
    end
  else
    return modelClass
  end
end

--- Assigns a model to the vortigaunt animation class.
--
-- @param model [String Model path]
-- @return [String The lowercased model path]
function cw.animation:AddVortigauntModel(model)
  return self:AddModel('vortigaunt', model)
end

--- Assigns a model to the Combine Overwatch animation class.
--
-- @param model [String Model path]
-- @return [String The lowercased model path]
function cw.animation:AddCombineOverwatchModel(model)
  return self:AddModel('combineOverwatch', model)
end

--- Assigns a model to the Civil Protection animation class.
--
-- @param model [String Model path]
-- @return [String The lowercased model path]
function cw.animation:AddCivilProtectionModel(model)
  return self:AddModel('civilProtection', model)
end

--- Assigns a model to the female Civil Protection animation class.
--
-- @param model [String Model path]
-- @return [String The lowercased model path]
function cw.animation:AddFemaleCivilProtectionModel(model)
  return self:AddModel('femaleCP', model)
end

--- Assigns a model to the female human animation class.
--
-- @param model [String Model path]
-- @return [String The lowercased model path]
function cw.animation:AddFemaleHumanModel(model)
  return self:AddModel('femaleHuman', model)
end

--- Assigns a model to the male human animation class.
--
-- @param model [String Model path]
-- @return [String The lowercased model path]
function cw.animation:AddMaleHumanModel(model)
  return self:AddModel('maleHuman', model)
end

do
  local translateHoldTypes = {
    [''] = 'normal',
    ['physgun'] = 'smg',
    ['ar2'] = 'smg',
    ['crossbow'] = 'shotgun',
    ['rpg'] = 'shotgun',
    ['slam'] = 'normal',
    ['grenade'] = 'normal',
    ['fist'] = 'normal',
    ['melee2'] = 'melee',
    ['passive'] = 'normal',
    ['knife'] = 'melee',
    ['revolver'] = 'pistol'
  }

  local weaponHoldTypes = {
    ['weapon_ar2'] = 'smg',
    ['weapon_smg1'] = 'smg',
    ['weapon_physgun'] = 'smg',
    ['weapon_crossbow'] = 'smg',
    ['weapon_physcannon'] = 'smg',
    ['weapon_crowbar'] = 'melee',
    ['weapon_bugbait'] = 'melee',
    ['weapon_stunstick'] = 'melee',
    ['gmod_tool'] = 'pistol',
    ['weapon_357'] = 'pistol',
    ['weapon_pistol'] = 'pistol',
    ['weapon_frag'] = 'grenade',
    ['weapon_slam'] = 'grenade',
    ['weapon_rpg'] = 'shotgun',
    ['weapon_shotgun'] = 'shotgun',
    ['weapon_annabelle'] = 'shotgun',
    ['sxbase_m9'] = 'pistol',
    ['sxbase_ar2'] = 'smg',
    ['sxbase_ar21'] = 'smg',
    ['sxbase_mp7'] = 'smg',
    ['sxbase_m40a1'] = 'smg',
    ['sxbase_spas12'] = 'smg',
    ['sxbase_ak74'] = 'smg',
    ['sxbase_uspmatch'] = 'pistol',
    ['sxbase_stunstick'] = 'melee',
    ['sxbase_crowbar'] = 'melee',
    ['sxbase_fireaxe'] = 'melee',
    ['sxbase_he'] = 'grenade',
    ['sxbase_sg'] = 'grenade',
    ['sxbase_fg'] = 'grenade',
    ['grub_combine_sniper'] = 'smg',
    ['sxbase_m9_2'] = 'pistol',
    ['sxbase_ak74n_2'] = 'smg',
    ['sxbase_ak74n'] = 'smg',
    ['sxbase_m40a1_2'] = 'smg',
    ['sxbase_m40a1optic_2'] = 'smg',
    ['sxbase_m40a1optic'] = 'smg',
    ['sxbase_mp7_s'] = 'smg',
    ['sxbase_mp7_ls'] = 'smg',
    ['sxbase_mp7_s_ls'] = 'smg',
    ['sxbase_mp7_bsk_ls'] = 'smg',
    ['sxbase_mp7_s_bsk_ls'] = 'smg',
    ['sxbase_mp7_micro_ls'] = 'smg',
    ['sxbase_mp7_s_micro_ls'] = 'smg'
  }

  -- This runs for every player on every frame, so the lookups are remembered per weapon class and hold type.
  local classHoldTypes = {}
  local holdTypes = {}

  --- Returns the hold type used to animate a weapon.
  --
  -- Known weapon classes have a fixed hold type. Otherwise the weapon's `HoldType` is used,
  -- mapped to one of the hold types Catwork animates (for example `ar2` becomes `smg`).
  --
  -- @param player [Player The player holding the weapon, unused]
  -- @param weapon [Weapon The weapon]
  -- @return [String The lowercased hold type; `'normal'` when the weapon has none]
  function cw.animation:GetWeaponHoldType(player, weapon)
    local class = weapon:GetClass()
    local holdType = classHoldTypes[class]

    if holdType == nil then
      holdType = weaponHoldTypes[string.lower(class)] or false
      classHoldTypes[class] = holdType
    end

    if holdType then
      return holdType
    end

    local weaponHoldType = weapon.HoldType

    if !weaponHoldType then
      return 'normal'
    end

    holdType = holdTypes[weaponHoldType]

    if !holdType then
      holdType = string.lower(translateHoldTypes[weaponHoldType] or weaponHoldType)
      holdTypes[weaponHoldType] = holdType
    end

    return holdType
  end
end

--- Returns the animation table for a model.
--
-- Models without an assigned class use the female human table when their path contains `female`
-- and the male human table otherwise.
--
-- @param model [String Model path]
-- @return [Map Animations keyed by hold type, or `nil` for models in a `/player/` folder]
function cw.animation:GetTable(model)
  local lowerModel = string.lower(model)

  if string.find(lowerModel, '/player/', 1, true) then
    return nil
  end

  local class = models[lowerModel]

  if class and stored[class] then
    return stored[class]
  elseif string.find(lowerModel, 'female') then
    return stored.femaleHuman
  else
    return stored.maleHuman
  end
end

local handsModels = {}
local blackModels = {}

--- Sets the viewmodel hands used for models whose path contains a string.
--
-- @param model [String Part of the model path; case is ignored]
-- @param hands [Map Hands info with `model`, `skin` and `body` keys]
-- @see cw.animation:GetHandsInfo
function cw.animation:AddHandsModel(model, hands)
  handsModels[string.lower(model)] = hands
end

--- Makes models whose path contains a string use the black skin on citizen and refugee hands.
--
-- @param model [String Part of the model path, such as `'/male_01.mdl'`]
function cw.animation:AddBlackModel(model)
  blackModels[string.lower(model)] = true
end

--- Makes models whose path contains a string use the citizen hands with the zombie skin.
--
-- @param model [String Part of the model path]
function cw.animation:AddZombieHands(model)
  self:AddHandsModel(model, {
    body = 0000000,
    model = 'models/weapons/c_arms_citizen.mdl',
    skin = 2
  })
end

--- Makes models whose path contains a string use the HEV suit viewmodel hands.
--
-- @param model [String Part of the model path]
function cw.animation:AddHEVHands(model)
  self:AddHandsModel(model, {
    body = 0000000,
    model = 'models/weapons/c_arms_hev.mdl',
    skin = 0
  })
end

--- Makes models whose path contains a string use the Combine viewmodel hands.
--
-- @param model [String Part of the model path]
function cw.animation:AddCombineHands(model)
  self:AddHandsModel(model, {
    body = 0000000,
    model = 'models/weapons/c_arms_combine.mdl',
    skin = 0
  })
end

--- Makes models whose path contains a string use the Counter-Strike: Source viewmodel hands.
--
-- @param model [String Part of the model path]
function cw.animation:AddCSSHands(model)
  self:AddHandsModel(model, {
    body = 0000000,
    model = 'models/weapons/c_arms_cstrike.mdl',
    skin = 0
  })
end

--- Makes models whose path contains a string use the refugee viewmodel hands.
--
-- @param model [String Part of the model path, such as `'/group03/'`]
function cw.animation:AddRefugeeHands(model)
  self:AddHandsModel(model, {
    body = 01,
    model = 'models/weapons/c_arms_refugee.mdl',
    skin = 0
  })
end

--- Makes models whose path contains a string use the refugee hands with the zombie skin.
--
-- @param model [String Part of the model path]
function cw.animation:AddZombieRefugeeHands(model)
  self:AddHandsModel(model, {
    body = 0000000,
    model = 'models/weapons/c_arms_refugee.mdl',
    skin = 2
  })
end

--- Returns the viewmodel hands info for a model.
--
-- Starts from the citizen hands, then the animation table's `hands`, then the first matching
-- entry added with `cw.animation:AddHandsModel`, and applies `cw.animation:AdjustHandsInfo`.
--
-- @param model [String Lowercased model path]
-- @param animTable=nil [Map The model's animation table]
-- @return [Map Hands info with `model`, `skin` and `body` keys]
function cw.animation:CheckHands(model, animTable)
  local info = {
    body = 0000000,
    model = 'models/weapons/c_arms_citizen.mdl',
    skin = 0
  }

  if animTable and animTable.hands then
    info = animTable.hands
  end

  for k, v in pairs(handsModels) do
    if string.find(model, k, 1, true) then
      info = v

      break
    end
  end

  -- The info is adjusted in place, which must not reach the tables it was picked from.
  info = table.Copy(info)

  self:AdjustHandsInfo(model, info)

  return info
end

--- Adjusts hands info for a model in place.
--
-- Citizen and refugee hands get the black skin for models added with
-- `cw.animation:AddBlackModel`. Then runs the `AdjustCModelHandsInfo` hook (via `hook.Run`) with
-- the model and the info.
--
-- @param model [String Lowercased model path]
-- @param info [Map Hands info with `model`, `skin` and `body` keys; changed in place]
function cw.animation:AdjustHandsInfo(model, info)
  if info.model == 'models/weapons/c_arms_citizen.mdl' or info.model == 'models/weapons/c_arms_refugee.mdl' then
    for k, v in pairs(blackModels) do
      if string.find(model, k, 1, true) then
        info.skin = 1

        break
      elseif info.skin == 1 then
        info.skin = 0
      end
    end
  end

  hook.Run('AdjustCModelHandsInfo', model, info)
end

--- Returns the viewmodel hands a model should use.
--
-- @param model [String Model path]
-- @return [Map Hands info with `model`, `skin` and `body` keys]
function cw.animation:GetHandsInfo(model)
  local animTable = self:GetTable(model)

  return self:CheckHands(string.lower(model), animTable)
end

cw.animation:AddBlackModel('/male_01.mdl')
cw.animation:AddBlackModel('/male_03.mdl')
cw.animation:AddBlackModel('/female_03.mdl')

cw.animation:AddRefugeeHands('/group03/')
cw.animation:AddRefugeeHands('/group03m/')

cw.animation:AddZombieRefugeeHands('/Zombie/')

cw.animation:AddVortigauntModel('models/vortigaunt.mdl')
cw.animation:AddVortigauntModel('models/vortigaunt_slave.mdl')
cw.animation:AddVortigauntModel('models/vortigaunt_doctor.mdl')

cw.animation:AddCombineOverwatchModel('models/combine_soldier_prisonguard.mdl')
cw.animation:AddCombineOverwatchModel('models/combine_super_soldier.mdl')
cw.animation:AddCombineOverwatchModel('models/combine_soldier.mdl')

cw.animation:AddCivilProtectionModel('models/police.mdl')
