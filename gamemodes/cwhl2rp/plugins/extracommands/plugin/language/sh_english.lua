--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

local lang = cw.lang:GetTable('en')

-- Notifications.
lang['#ExtraCommands_OverwatchSays'] = 'Overwatch broadcasts'
lang['#ExtraCommands_MessageTooShort'] = 'Your message must be 6 or more letters long!'
lang['#ExtraCommands_ArmorReset'] = "You have reset #1's armor to 100."
lang['#ExtraCommands_HealthReset'] = "You have reset #1's health to #2."
lang['#ExtraCommands_IconSet'] = "You have set #1's chat icon to:"
lang['#ExtraCommands_NotPng'] = 'is not a .png file!'
lang['#ExtraCommands_AttributeSet'] = "You have set #1's #2 [#3] attribute to #4."
lang['#ExtraCommands_NotValidAttribute'] = '#1 is not a valid attribute!'

-- Commands.
lang['#Command_Overwatch_Description'] = 'Sends a message to all Civil Protection units.'
lang['#Command_Overwatch_Syntax'] = '<string Message>'
lang['#Command_Plyresetarmor_Description'] = "Resets a player's armor to the maximum amount."
lang['#Command_Plyresetarmor_Syntax'] = '<string Player>'
lang['#Command_Plyresethealth_Description'] = "Resets a player's health to the maximum amount."
lang['#Command_Plyresethealth_Syntax'] = '<string Player>'
lang['#Command_Charsetskin_Description'] = "Sets a player's skin."
lang['#Command_Charsetskin_Syntax'] = '<string Player> <number Skin Index>'
lang['#Command_Charsetbodygroup_Description'] = "Sets a player's bodygroup."
lang['#Command_Charsetbodygroup_Syntax'] = '<string Player> <number BodyGroup> [number BodyGroup Value]'
lang['#Command_Plyseticon_Description'] = "Sets a player's chat icon."
lang['#Command_Plyseticon_Syntax'] = '<string Player> <string Path or URL>'
lang['#Command_Charsetattribute_Description'] = "Sets an attribute's value for a character."
lang['#Command_Charsetattribute_Syntax'] = '<string Player> <string Attribute> <number Amount>'
