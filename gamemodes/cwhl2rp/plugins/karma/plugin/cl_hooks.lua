--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

-- Called when the player info text is needed.
function cwKarma:GetPlayerInfoText(playerInfoText)
	playerInfoText:Add("KARMA", L("#Karma")..": "..L(cw.client:GetKarmaLevel()))
end

local mat_karma = Material("materials/catwork/karma_bar.png")

function cwKarma:PaintInfoMenuExtras(info)
	local x, y, w, h = info.x, info.y, info.width, info.height
	local adjust = 0
	local karma = cw.client:GetKarma()
	local normal = karma / 100

	cw.core:DrawInfo("#Karma_InfoMenu", x, y, cw.option:GetColor("information"), nil, true, function(x, y, width, height)
		adjust = adjust + height + 4

		return x, y
	end)

	y = y + adjust

	draw.RoundedBox(4, x, y, w, 64, Color(0, 0, 0))

	local barWidth = w - 32

	draw.TexturedRect(x + 16, y + 18, barWidth, 28, mat_karma)

	local centerPos = x + 16 + (barWidth / 2 - 2) 
	local sliderPos = centerPos + ((barWidth / 2) * normal)

	draw.RoundedBox(0, sliderPos, y + 14, 4, 36, Color(255, 255, 255))

	adjust = adjust + 70

	info:Adjust(adjust)
end

function cwKarma:DrawPlayerStatusExtra(entity, alpha, x, y)
	if (entity:IsPlayer() and !entity:IsCombine() and cw.player:DoesRecognise(entity)) then
		local font = cw.option:GetFont("target_id_text")
		local w, h = util.GetTextSize(font, entity:GetKarmaLevel())

		draw.SimpleText(entity:GetKarmaLevel(), font, x - w / 2, y, cw.option:GetColor("information"))

		return y + h
	end
end
