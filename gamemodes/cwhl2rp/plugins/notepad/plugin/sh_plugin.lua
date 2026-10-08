--- Main file of the Notepad plugin, which adds notepads that players can place and write on; exposes the plugin as
-- `cwNotepad`, creates the `cwNotepad.notepadIDs` text cache and includes the plugin's client and server files.

local PLUGIN = PLUGIN

PLUGIN:SetGlobalAlias('cwNotepad')

cwNotepad.notepadIDs = cwNotepad.notepadIDs or {}

util.Include('cl_plugin.lua')
util.Include('cl_hooks.lua')
util.Include('sv_plugin.lua')
util.Include('sv_hooks.lua')
