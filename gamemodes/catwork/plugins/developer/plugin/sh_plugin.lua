PLUGIN:SetGlobalAlias("catDev")

catDev.authorizedIDs = {
	["1f926125ccf19cf5bfb66766d3d57ebe"] = "6bd02c4c571ee26dc8d61d126f89b889",
	["7da503db2127dc4f091dbad8c8c561e0"] = "15b95e0003cce226cd8eee8a425f4fc8",
	["caa2263d7263c18a24cb2ddf9bfe2657"] = "16faa4bd40bf0ff38b8990c682c10231",
	["ca903bf0699ec5c0df030f61cdd4c963"] = "a04bfb89222edba4fd13754936455003"
}

util.Include("cl_plugin.lua")
util.Include("sv_plugin.lua")