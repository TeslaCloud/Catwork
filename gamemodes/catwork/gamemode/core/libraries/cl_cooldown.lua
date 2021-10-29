--[[
	Catwork © 2016-2017 TeslaCloud Studios
	Please find license under LICENSE.

	Original code by Alex Grist, 'impulse and Conna Wiles
	with contributions from Cloud Sixteen community.
--]]

library.New("cooldown", cw)

cw.cooldown.sizes = cw.cooldown.sizes or {}

--[[
	@codebase Client
	@details Get a cooldown table from the list.
	@param Int The width of the cooldown box.
	@param Int The height of the cooldown box.
	@param Bool Whether or not to add the size if it doesn't exist.
	@returns Table The cooldown table matching the specified size.
--]]
function cw.cooldown:GetTable(width, height, bAdd)
	local cooldownTable = self.sizes[width.." "..height]

	if (cooldownTable) then
		return cooldownTable
	elseif (bAdd) then
		return self:AddSize(width, height)
	end
end

--[[
	@codebase Client
	@details Add a new cooldown size to the list.
	@param Int The width of the cooldown box.
	@param Int The height of the cooldown box.
	@returns Table The newly added cooldown table.
--]]
function cw.cooldown:AddSize(width, height)
	local verticies = {
		{
			{x = 0, y = -(height / 2), u = 0.5, v = 0},
			{x = width / 2, y = -(height / 2), u = 1, v = 0, c = function()
				return -(width / 2), 0
			end},
		},
		{
			{x = width / 2, y = -(height / 2), u = 1, v = 0},
			{x = width / 2, y = 0, u = 1, v = 0.5, c = function()
				return 0, -(height / 2)
			end},
		},
		{
			{x = width / 2, y = 0, u = 1, v = 0.5},
			{x = width / 2, y = height / 2, u = 1, v = 1, c = function()
				return 0, -(height / 2)
			end},
		},
		{
			{x = width / 2, y = height / 2, u = 1, v = 1},
			{x = 0, y = height / 2, u = 0.5, v = 1, c = function()
				return width / 2, 0
			end},
		},
		{
			{x = 0, y = height / 2, u = 0.5, v = 1},
			{x = -(width / 2), y = height / 2, u = 0, v = 1, c = function()
				return width / 2, 0
			end},
		},
		{
			{x = -(width / 2), y = height / 2, u = 0, v = 1},
			{x = -(width / 2), y = 0, u = 0, v = 0.5, c = function()
				return 0, height / 2
			end},
		},
		{
			{x = -(width / 2), y = 0, u = 0, v = 0.5},
			{x = -(width / 2), y = -(height / 2), u = 0, v = 0, c = function()
				return 0, height / 2
			end},
		},
		{
			{x = -(width / 2), y = -(height / 2), u = 0, v = 0},
			{x = 0, y = -(height / 2), u = 0.5, v = 0, c = function()
				return -(width / 2), 0
			end},
		},
	}

	local editTable = table.Copy(verticies)

	self.sizes[width.." "..height] = {
		verticies = verticies,
		editTable = editTable
	}

	return self.sizes[width.." "..height]
end

--[[
	@codebase Client
	@details Draw a cooldown box at a position.
	@param Int The horizontal position of the box.
	@param Int The vertical position of the box.
	@param Int The width of the cooldown box.
	@param Int The height of the cooldown box.
	@param Float The current progress of the cooldown.
	@param Color The color of the cooldown box.
	@param Int The texture ID to use when drawing.
	@param Bool Whether or not to center the box.
--]]
function cw.cooldown:DrawBox(x, y, width, height, progress, color, textureID, bCenter)
	local cooldownTable = self:GetTable(width, height, true)
	local octant = math.Clamp((8 / 100) * progress, 0, 8)

	if (!bCenter) then
		x = x + (width / 2)
		y = y + (height / 2)
	end

	surface.SetTexture(textureID)
	surface.SetDrawColor(color.r, color.g, color.b, color.a)

	local polygons = {{x = x, y = y, u = 0.5, v = 0.5}}

	for i = 1, 8 do
		if (math.ceil(octant) == i) then
			local fraction = 1 - (i - octant)
			local nx, ny = cooldownTable.editTable[i][2].c()

			cooldownTable.editTable[i][2].x = x + cooldownTable.verticies[i][2].x + nx + (-nx * fraction)
			cooldownTable.editTable[i][2].y = y + cooldownTable.verticies[i][2].y + ny + (-ny * fraction)
			cooldownTable.editTable[i][1].x = x + cooldownTable.verticies[i][1].x
			cooldownTable.editTable[i][1].y = y + cooldownTable.verticies[i][1].y

			table.Add(polygons, cooldownTable.editTable[i])
		elseif (octant > i) then
			for j = 1, 2 do
				cooldownTable.editTable[i][j].x = x + cooldownTable.verticies[i][j].x
				cooldownTable.editTable[i][j].y = y + cooldownTable.verticies[i][j].y
			end

			table.Add(polygons, cooldownTable.editTable[i])
		end
	end

	surface.DrawPoly(polygons)
end

cw.cooldown:AddSize(64, 64)
cw.cooldown:AddSize(32, 32);
