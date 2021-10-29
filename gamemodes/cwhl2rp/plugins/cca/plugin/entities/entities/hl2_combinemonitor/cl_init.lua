include("shared.lua")

local glow = CreateMaterial("_CMB_SMALLMONITOR_GLOW4", "UnlitGeneric", {
	["$basetexture"] = "sprites/glow06",
	["$additive"] = "1",
	["$selfilium"] = "1",
	["$vertexcolor"] = "1",
	["$vertexalpha"] = "1",
})

local errorc = CreateMaterial("_CMB_ERROR", "Modulate", {
	["$basetexture"] = "props/combine_monitor_access_off",
	["$ignorez"] = "1",
	["$vertexcolor"] = "1",
	["$vertexalpha"] = "1",
	["$translucent"] = "1",
})

surface.CreateFont("_CMB_FONT_1", {
	font = "Myriad Pro",
	size = 22,
	weight = 1000,
	antialias = true,
	underline = false,
	additive = true
})

surface.CreateFont("_CMB_FONT_2", {
	font = "Consolas",
	size = 20,
	weight = 1000,
	antialias = true,
	underline = false,
	additive = true
})

surface.CreateFont("_CMB_FONT_4", {
	font = "System",
	size = 72,
	weight = 1000,
	antialias = true,
	underline = false,
})

surface.CreateFont("_CMB_FONT_5", {
	font = "System",
	size = 9,
	weight = 500,
	antialias = false,
	underline = false,
})

function ENT:Initialize()
	self.RT = GetRenderTarget("_CMB_SMALLMONITOR_ENT"..self:EntIndex()..CurTime(), 256, 256, false)
	self.RTMat = CreateMaterial("_CMB_SMALLMONITOR_ENT_RTMAT" .. self:EntIndex() .. CurTime(), "UnlitTwoTexture", {
		["$selfilium"] = "1",
		["$texture2"] = "dev/dev_scanline",
		["Proxies"] = {
			["TextureScroll"] = {
				["texturescrollvar"] = "$texture2transform",
				["texturescrollrate"] = "3",
				["texturescrollangle"] = "90"
			}
		}
	})

	self.error = true
	self.errorFlash = CurTime()
end

-- СУКА Я ОРУ С ЭТИХ НАЗВАНИЙ ФУНКЦИЙ
local function bitkek(int)
	local str = ""

	for i = 0, int do
		str = str..math.random(0, 1)
	end

	return str
end

function ENT:DrawTranslucent()
	local pos = self:GetPos()
	local clientPos = cw.client:GetPos()
	local dist = clientPos:Distance(pos)

	if (dist < 1000) then
		self:DrawModel()

		local curTime = CurTime()
		local ang = self:GetAngles()

		ang:RotateAroundAxis(ang:Forward(), 90)
		ang:RotateAroundAxis(ang:Right(), -90)

		pos = pos + self:GetForward() * 13 + self:GetUp() * 19 + self:GetRight() * 6.8

		render.PushRenderTarget(self.RT)
			render.Clear(0, 50, 120, 255)
			cam.Start2D()
				local glow_text = math.abs(math.sin(curTime * 3) * 255)

				if (!self:GetNetVar("monitor_activated")) then
					surface.SetTextColor(100, 100, 255)
					surface.SetFont("_CMB_FONT_1")
					surface.SetTextPos(20, 15)
					surface.DrawText("Информационный стенд")
					surface.SetTextPos(90, 35)
					surface.DrawText(Schema.City)
					surface.SetTextColor(100, 100, 255, glow_text)
					surface.SetFont("_CMB_FONT_1")
					surface.SetTextPos(16, 256 - 128 - 4)
					surface.DrawText("Ожидается ввод данных...")
				else
					local data = self:GetNetVar("userData", {})

					if data.status == "#Status_AntiCitizen" then
						text = ""
						render.Clear(80, 0, 0, 255)
					end

					if (#data.name > 19) then
						data.name = string.sub(data.name, 1, 19 - 3) .. "..."
					end

					if (data.status != "#Status_AntiCitizen") then
						local offset = 20

						surface.SetTextColor(100, 100, 255)
						surface.SetFont("_CMB_FONT_1")

						surface.SetTextPos(20, 15)
						surface.DrawText("Информационный стенд")

						surface.SetTextPos(90, 35)
						surface.DrawText(Schema.City)

						surface.SetTextColor(100, 100, 255)
						surface.SetFont("_CMB_FONT_2")

						surface.SetTextPos(18, 65)
						surface.DrawText("Имя: "..data.name)

						surface.SetTextPos(18, 85)
						surface.DrawText("Идентификатор: #"..data.citizenID)

						surface.SetTextPos(18, 85 + offset)
						surface.DrawText("Лояльность: "..data.lp)

						surface.SetTextPos(18, 85 + (offset * 2))
						surface.DrawText("Нарушения: "..data.cp)

						surface.SetTextPos(18, 85 + (offset * 3))
						surface.DrawText("Труд: "..data.wp.." ("..data.workLevel.." ур.)")

						surface.SetTextPos(18, 85 + (offset * 4))
						surface.DrawText("Статус: "..data.status)

						surface.SetTextPos(18, 85 + (offset * 5))
						surface.DrawText("Прописка:\n"..string.utf8upper(data.residence))

						surface.SetTextPos(18, 85 + (offset * 6))
						surface.DrawText("Гражд. фракция: "..string.utf8upper(data.job))

						if (data.status == "#Status_Unverified") then
							surface.SetTextPos(18, 85 + (offset * 7))
							surface.DrawText("Подтвердите свой статус")

							surface.SetTextPos(68, 76 + (offset * 8))
							surface.DrawText("В отделе ГСР")
						end

						surface.SetDrawColor(100, 100, 255)
						surface.DrawRect(0, 65, 256, 2)
						surface.DrawRect(0, 85 + (offset * 7), 256, 2)
					else
						surface.SetTextColor(255, 0, 0)
						surface.SetFont("_CMB_FONT_4")
						surface.SetTextPos(10, 50)
						surface.DrawText("ERROR")

						if (curTime >= self.errorFlash) then
							self.error = !self.error
							self.errorFlash = curTime + 0.4
						end

						if (dist < 300) then
							surface.SetTextColor(255, 0, 0)
							surface.SetFont("_CMB_FONT_5")
							surface.SetTextPos(20, 140)
							surface.DrawText("1E"..string.upper(md5.sumhexa("b"..math.random(0, 9))))
							surface.SetTextPos(20, 155)
							surface.DrawText(bitkek(6).."cmb_ACCESS")
							surface.SetTextPos(20, 180)
							surface.DrawText(bitkek(2)..util.CRC(self:EntIndex())..bitkek(2).."CP_cmb"..bitkek(4))
							surface.SetTextPos(20, 220)
							surface.DrawText(string.upper(md5.sumhexa("b"..math.random(0, 9))))
							surface.SetTextPos(88, 50)
							surface.DrawText(bitkek(4).."cmb_biba"..bitkek(1).."systems"..bitkek(2).."failure"..bitkek(3))
						end
					end
				end
			cam.End2D()
		render.PopRenderTarget()

		self.RTMat:SetTexture("$basetexture", self.RT)

		cam.Start3D2D(pos, ang, 0.064)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(self.RTMat)
			surface.DrawTexturedRect(0, 0, 256, 256)
		cam.End3D2D()
	end
end