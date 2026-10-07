PLUGIN:SetGlobalAlias('catDev')

-- Plain SteamIDs of the developers.
catDev.authorizedIDs = {
  ['STEAM_0:1:14196407'] = true, -- Mr. Meow
  ['STEAM_0:1:44952839'] = true -- AleXXX_007
}

-- Legacy entries that are only known as hashes: [MD5 of the SteamID] = MD5 of the Steam name.
catDev.authorizedHashes = {
  ['caa2263d7263c18a24cb2ddf9bfe2657'] = '16faa4bd40bf0ff38b8990c682c10231',
  ['ca903bf0699ec5c0df030f61cdd4c963'] = 'a04bfb89222edba4fd13754936455003'
}

util.Include('sv_plugin.lua')
