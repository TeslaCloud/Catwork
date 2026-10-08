--- Main file of the Display Typing plugin, which aliases it as `cwDisplayTyping` and includes its files.
--
-- The plugin shows above a character's head that they are typing, and whether they are talking, whispering, yelling,
-- using the radio, performing an action or typing out of character.

--[[
  You don't have to do this, but I think it's nicer.
  Alternatively, you can simply use the PLUGIN variable.
--]]
PLUGIN:SetGlobalAlias('cwDisplayTyping')

--[[ You don't have to do this either, but I prefer to seperate the functions. --]]
util.Include('cl_hooks.lua')
util.Include('sv_plugin.lua')
util.Include('sv_hooks.lua')
util.Include('sh_enum.lua')
