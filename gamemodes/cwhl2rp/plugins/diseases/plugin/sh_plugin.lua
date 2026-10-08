--- Main file of the Diseases plugin, which adds diseases that characters catch at random or from food and the medicine
-- items that cure them; exposes the plugin as `cwDiseases`, lists the known diseases in `cwDiseases.stored` and
-- includes the plugin's client and server hooks and its flag definitions.

PLUGIN:SetGlobalAlias('cwDiseases')

-- Every value the `diseases` character data can take; `none` is a healthy character.
cwDiseases.stored = {
  none = true,
  cough = true,
  pneumonia = true,
  fever = true,
  gastrits = true,
  allergy = true,
  insomnia = true,
  diarrhea = true,
  blindness = true,
  colorblindness = true,
  slow_deathinjection = true,
  fast_deathinjection = true
}

util.Include('cl_hooks.lua')
util.Include('sv_hooks.lua')
util.Include('sh_schema.lua')
