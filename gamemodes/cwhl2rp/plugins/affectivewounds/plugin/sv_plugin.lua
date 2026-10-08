--- Server-side part of the Affective wounds plugin, which adds its configs: `affectivewounds_enabled`,
-- `affectivewounds_legshotlimit`, `affectivewounds_armshotlimit` and the `affectivewounds_affect...` and
-- `affectivewounds_additionalhits...` keys for Overwatch (`ota`) and Civil Protection (`mpf`).

config.Add('affectivewounds_enabled', true, true)
config.Add('affectivewounds_legshotlimit', 1, true)
config.Add('affectivewounds_armshotlimit', 1, true)
config.Add('affectivewounds_affectota', false, true)
config.Add('affectivewounds_affectmpf', true, true)
config.Add('affectivewounds_additionalhitsota', 2, true)
config.Add('affectivewounds_additionalhitsmpf', 1, true)
