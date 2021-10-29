--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

PLUGIN:SetGlobalAlias("cwNotepad");

cwNotepad.notepadIDs = cwNotepad.notepadIDs or {};

util.Include("cl_plugin.lua");
util.Include("cl_hooks.lua");
util.Include("sv_plugin.lua");
util.Include("sv_hooks.lua");