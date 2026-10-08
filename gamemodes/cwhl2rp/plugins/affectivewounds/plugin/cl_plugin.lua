--- Adds the configs of the Affective wounds plugin to the system config menu: `affectivewounds_enabled`, the leg and
-- arm hit limits, and the `affectota`, `affectmpf`, `additionalhitsota` and `additionalhitsmpf` settings for Overwatch
-- and Civil Protection.

config.AddToSystem('#AffectiveWounds_Enabled', 'affectivewounds_enabled', '#AffectiveWounds_EnabledDesc')
config.AddToSystem(
  '#AffectiveWounds_LegShotLimit',
  'affectivewounds_legshotlimit',
  '#AffectiveWounds_LegShotLimitDesc',
  1,
  10
)
config.AddToSystem(
  '#AffectiveWounds_ArmShotLimit',
  'affectivewounds_armshotlimit',
  '#AffectiveWounds_ArmShotLimitDesc',
  1,
  10
)
config.AddToSystem('#AffectiveWounds_AffectOTA', 'affectivewounds_affectota', '#AffectiveWounds_AffectOTADesc')
config.AddToSystem('#AffectiveWounds_AffectMPF', 'affectivewounds_affectmpf', '#AffectiveWounds_AffectMPFDesc')
config.AddToSystem(
  '#AffectiveWounds_AdditionalHitsOTA',
  'affectivewounds_additionalhitsota',
  '#AffectiveWounds_AdditionalHitsOTADesc',
  0,
  10
)
config.AddToSystem(
  '#AffectiveWounds_AdditionalHitsMPF',
  'affectivewounds_additionalhitsmpf',
  '#AffectiveWounds_AdditionalHitsMPFDesc',
  0,
  10
)
