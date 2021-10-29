PLUGIN:SetGlobalAlias("cwCTO")

cwCTO.sociostatusColors = {
	GREEN = Color(0, 255, 0),
	BLUE = Color(0, 128, 255),
	YELLOW = Color(255, 255, 0),
	RED = Color(255, 0, 0),
	BLACK = Color(128, 128, 128)
}

-- Biosignal change enums, used for player/admin command language variations.
cwCTO.ERROR_NONE = 0
cwCTO.ERROR_NOT_COMBINE = 1
cwCTO.ERROR_ALREADY_ENABLED = 2
cwCTO.ERROR_ALREADY_DISABLED = 3

-- Movement violation enums, used when networking cameras.
cwCTO.VIOLATION_RUNNING = 0
cwCTO.VIOLATION_JOGGING = 1
cwCTO.VIOLATION_JUMPING = 2
cwCTO.VIOLATION_CROUCHING = 3
cwCTO.VIOLATION_FALLEN_OVER = 4

util.Include("cl_hooks.lua")
util.Include("sv_plugin.lua")