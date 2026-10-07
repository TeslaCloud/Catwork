--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local lang = cw.lang:GetTable('en')

lang['#Door_Vacant'] = 'Vacant'

-- Notifications.
lang['#PermaDoors_Assigned'] = 'This door was successfully assigned to #1.'
lang['#PermaDoors_OwnerRemoved'] = "This door's owner has been removed."
lang['#PermaDoors_NotValidDoor'] = 'This is not a valid door!'

-- Commands.
lang['#Command_Doorsetplayer_Description'] = 'Assigns the door to a certain player.'
lang['#Command_Doorsetplayer_Syntax'] = '<string Player> <string Door Title>'
lang['#Command_Doorresetplayer_Description'] = 'Removes the currently assigned player from the door.'
lang['#Command_Doorresetplayer_Syntax'] = '<string Door Title>'
