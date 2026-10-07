--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

local lang = cw.lang:GetTable("en")

-- HUD
lang["#CTO_HUD_Lost"] = "Lost #1s ago"
lang["#CTO_HUD_Received"] = "Received #1s ago"
lang["#CTO_HUD_Removal"] = "Removal in #1s"
lang["#CTO_HUD_Unconscious"] = "Unconscious"
lang["#CTO_HUD_Request"] = "Assistance request"
lang["#CTO_HUD_InView"] = "#1 in view"
lang["#CTO_HUD_ViolationsInView"] = "Violations in view"
lang["#CTO_HUD_PossibleViolation"] = "Possible violation"
lang["#CTO_HUD_Violation_Running"] = "Running"
lang["#CTO_HUD_Violation_Jumping"] = "Jumping"
lang["#CTO_HUD_Violation_Crouching"] = "Crouching"
lang["#CTO_HUD_Violation_FallenOver"] = "Lying down"
lang["#CTO_HUD_Disabled"] = "Disabled"
lang["#CTO_HUD_SocioStatus"] = "Sociostatus: #1"

-- Commands
lang["#Command_Cameradisable_Description"] = "Remotely disable a Combine camera - IDs are shown on the HUD."
lang["#Command_Cameradisable_Syntax"] = "<number CameraID>"
lang["#Command_Cameraenable_Description"] = "Remotely enable a Combine camera - IDs are shown on the HUD."
lang["#Command_Cameraenable_Syntax"] = "<number CameraID>"
lang["#Command_Charsetbiosignalstatus_Description"] = "Turn a character's biosignal on or off."
lang["#Command_Charsetbiosignalstatus_Syntax"] = "<string Name> <bool Enabled>"
lang["#Command_Setbiosignalstatus_Description"] = "Turn your biosignal on or off. This will alert all other units."
lang["#Command_Setbiosignalstatus_Syntax"] = "<bool Enabled>"
lang["#Command_Setsociostatus_Description"] = "Update the sociostability status of the city."
lang["#Command_Setsociostatus_Syntax"] = "<string green|blue|yellow|red|black>"

lang["#CTO_NotCombine"] = "You are not the Combine!"
lang["#CTO_RankTooLow"] = "You are not ranked high enough to use this command!"
lang["#CTO_NoCamera"] = "There is no Combine camera with that ID!"
lang["#CTO_CameraNotEnabled"] = "That camera is not currently enabled."
lang["#CTO_CameraNotDisabled"] = "That camera is not currently disabled."
lang["#CTO_DisablingCamera"] = "Disabling C-i#1."
lang["#CTO_EnablingCamera"] = "Enabling C-i#1."
lang["#CTO_CharNotCombine"] = "That character is not the Combine!"
lang["#CTO_CharBiosignalAlreadyOn"] = "That character's biosignal is already enabled!"
lang["#CTO_CharBiosignalAlreadyOff"] = "That character's biosignal is already disabled!"
lang["#CTO_BiosignalAlreadyOn"] = "Your biosignal is already enabled!"
lang["#CTO_BiosignalAlreadyOff"] = "Your biosignal is already disabled!"
lang["#CTO_InvalidSocioStatus"] = "That is not a valid sociostatus!"

-- Combine display lines
lang["#CTO_Display_DownloadingLostBiosignal"] = "Downloading lost biosignal..."
lang["#CTO_Display_ConnectionRestored"] = "Connection restored..."
lang["#CTO_Display_DownloadingFoundBiosignal"] = "Downloading found biosignal..."
lang["#CTO_Display_BiosignalFound"] = "ALERT! Noncohesive biosignal found for unit #1. Location: #2..."
lang["#CTO_Display_ShuttingDown"] = "ERROR! Shutting down..."
lang["#CTO_Display_DownloadingTrauma"] = "Downloading trauma data..."
lang["#CTO_Display_UnitUnconscious"] = "WARNING! Unit #1 has lost consciousness. Location: #2..."
lang["#CTO_Display_SocioStatusUpdated"] = "ALERT! Sociostatus updated to #1!"
