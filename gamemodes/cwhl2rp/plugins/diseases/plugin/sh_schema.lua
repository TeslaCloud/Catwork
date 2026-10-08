--- Registers the flags of the Diseases plugin: `q` for access to light medicaments and `Q` for access to heavy
-- medicaments.

local PLUGIN = PLUGIN

cw.flag:Add('q', 'Light Medicaments', 'Access to light medicaments.')
cw.flag:Add('Q', 'Heavy Medicaments', 'Access to heavy medicaments.')
