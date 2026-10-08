--- Client-side file of the Third Person plugin that adds the `cwThirdPerson` checkbox to the Framework category of the
-- settings menu.

local PLUGIN = PLUGIN

cw.setting:AddCheckBox('#Framework', '#ThirdPerson_Enable', 'cwThirdPerson', '#ThirdPerson_EnableDesc')
