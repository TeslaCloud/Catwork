--[[
	(C) 2016 TeslaCloud Studios
	For internal distribution only.
--]]

library.New("cdraw", _G)

cdraw.Blur = Material("pp/blurscreen")

if (!_G["ClockworkClientsideBooted"]) then
	-- Create all font sizes at once. I am just too tired of creating a new font for each size I wanna use.
	for i = 1, 72 do
		surface.CreateFont("Derma"..i, {
			font = "Roboto",
			size = i,
			weight = 500,
			extended = true
		})

		surface.CreateFont("DermaNarrow"..i, {
			font = "RobotoCondensed",
			size = i,
			weight = 400,
			extended = true
		})

		surface.CreateFont("DermaNarrowBold"..i, {
			font = "RobotoCondensed",
			size = i,
			weight = 800,
			extended = true
		})

		surface.CreateFont("Exo"..i, {
			font = "Exo 2",
			size = i,
			weight = 400,
			extended = true
		})

		surface.CreateFont("ExoBold"..i, {
			font = "Exo 2",
			size = i,
			weight = 800,
			extended = true
		})

		surface.CreateFont("DermaBold"..i, {
			font = "Roboto",
			size = i,
			weight = 1000,
			extended = true
		})

		surface.CreateFont("DermaThin"..i, {
			font = "Roboto",
			size = i,
			weight = 150,
			extended = true
		})

		surface.CreateFont("DermaGlow"..i, {
			font = "Roboto",
			size = i,
			blursize = 4,
			scanlines = 2,
			weight = 500,
			extended = true
		})
	end
end

function util.GetTextSize(font, text)
	surface.SetFont(font)

	return surface.GetTextSize(text)
end

function cdraw.DrawBox(x, y, w, h, color, RoundAmt)
	RoundAmt = RoundAmt or 4
	color = color or Color(200, 200, 200)
	draw.RoundedBox(RoundAmt, x, y, w, h, color)
end

function cdraw.DrawText(text, x, y, size, color, font)
	font = font or "Derma"
	surface.SetFont(font..size)
	surface.SetTextColor(color)
	surface.SetTextPos(x, y)
	surface.DrawText(text)
end

-- Requires to be executed within a panel.
function cdraw.DrawSimpleBlurBox(x, y, w, h, color, blurAmt)
	blurAmt = blurAmt or 4

	cdraw.DrawBox(0, 0, w, h, color)

	surface.SetMaterial(cdraw.Blur)
	surface.SetDrawColor(255, 255, 255, 255)

	for i = -0.2, 1, 0.2 do
		cdraw.Blur:SetFloat("$blur", i * blurAmt)
		cdraw.Blur:Recompute()

		render.UpdateScreenEffectTexture()

		render.SetScissorRect(x, y, x + w, y + h, true)
			surface.DrawTexturedRect(-x, -y, ScrW(), ScrH())
		render.SetScissorRect(0, 0, 0, 0, false)
	end
end

-- More advanced way to do blur boxes.
function cdraw.DrawBlurBox(px, py, x, y, w, h, color, blurAmt)
	blurAmt = 4

	cdraw.DrawBox(x, y, w, h, color)

	surface.SetMaterial(cdraw.Blur)
	surface.SetDrawColor(255, 255, 255, 255)

	for i = -0.2, 1, 0.2 do
		cdraw.Blur:SetFloat("$blur", i * blurAmt)
		cdraw.Blur:Recompute()

		render.UpdateScreenEffectTexture()

		render.SetScissorRect(px, py, w, h, true)
			surface.DrawTexturedRect(-px, -py, ScrW(), ScrH())
		render.SetScissorRect(0, 0, 0, 0, false)
	end
end

function cdraw.DrawPanelBase(name, x, y, w, h)
	cdraw.DrawBox(x, y, w, h, cw.option:GetColor("panel_primarycolor"))
end

function cdraw.DrawEZPoly(x1, y1, w, h, pct, col)
	local poly = {
		{x = x1, y = y1},
		{x = x1 + w, y = y1},
		{x = x1 + w + pct, y = y1 + h},
		{x = x1 + pct, y = y1 + h}
	}

	surface.SetDrawColor(col)
	draw.NoTexture()
	surface.DrawPoly(poly)
end

function cdraw.DrawEZHalfPoly(x1, y1, w, h, pct, col)
	local poly = {
		{x = x1, y = y1},
		{x = x1 + w, y = y1},
		{x = x1 + w + pct, y = y1 + h},
		{x = x1, y = y1 + h}
	}

	surface.SetDrawColor(col)
	draw.NoTexture()
	surface.DrawPoly(poly)
end

function cdraw.DrawEZHalfPolyRight(x1, y1, w, h, pct, col)
	local poly = {
		{x = x1, y = y1},
		{x = x1 + w, y = y1},
		{x = x1 + w, y = y1 + h},
		{x = x1 - pct, y = y1 + h}
	}

	surface.SetDrawColor(col)
	draw.NoTexture()
	surface.DrawPoly(poly)
end

function cdraw.PolyBar(x, y, w, h, pct, col)
	cdraw.DrawEZHalfPoly(x, y, w, h, 32, Color(65, 65, 65, 190))

	if ((pct / 100) != 0) then
		cdraw.DrawEZHalfPoly(x + 1, y + 1, (w - 2) * (pct / 100), h - 2, 32, col)
	end
end