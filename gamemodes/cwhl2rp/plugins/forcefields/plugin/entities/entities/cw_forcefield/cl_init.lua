include("shared.lua");

local material = Material("effects/com_shield003a");

function ENT:Initialize()
	local data = {};
	data.start = self:GetPos() + Vector(0, 0, 50) + self:GetRight() * -16;
	data.endpos = self:GetPos() + Vector(0, 0, 50) + self:GetRight() * -600;
	data.filter = self;
	local trace = util.TraceLine(data);

	local verts = {
		{pos = Vector(0, 0, -35)},
		{pos = Vector(0, 0, 150)},
		{pos = self:WorldToLocal(trace.HitPos - Vector(0, 0, 50)) + Vector(0, 0, 150)},
		{pos = self:WorldToLocal(trace.HitPos - Vector(0, 0, 50)) + Vector(0, 0, 150)},
		{pos = self:WorldToLocal(trace.HitPos - Vector(0, 0, 50)) - Vector(0, 0, 35)},
		{pos = Vector(0, 0, -35)},
	};

	self:PhysicsFromMesh(verts);
	self:EnableCustomCollisions(true);
end;

function ENT:Draw()
	local post = self:GetDTEntity(0);
	local angles = self:GetAngles();
	local matrix = Matrix();

	self:DrawModel();
	matrix:Translate(self:GetPos() + self:GetUp() * -40 + self:GetForward() * -2);
	matrix:Rotate(angles);

	render.SetMaterial(material);

	if (IsValid(post)) then
		local vertex = self:WorldToLocal(post:GetPos());
		self:SetRenderBounds(vector_origin - Vector(0, 0, 40), vertex + self:GetUp() * 150);

		cam.PushModelMatrix(matrix);
		self:DrawShield(vertex);
		cam.PopModelMatrix();

		matrix:Translate(vertex);
		matrix:Rotate(Angle(0, 180, 0));

		cam.PushModelMatrix(matrix);
		self:DrawShield(vertex);
		cam.PopModelMatrix();
	end;
end;

-- I took a peek at how Chessnut drew his forcefields.
function ENT:DrawShield(vertex)
	if (self:GetDTInt(0) != 4) then
		local dist = self:GetDTEntity(0):GetPos():Distance(self:GetPos())
		local matFac = 45
		local height = 5
		local width = dist / matFac
		mesh.Begin(MATERIAL_QUADS, 1)
		mesh.Position(vector_origin)
		mesh.TexCoord(0, 0, 0)
		mesh.AdvanceVertex()
		mesh.Position(self:GetUp() * 190)
		mesh.TexCoord(0, 0, height)
		mesh.AdvanceVertex()
		mesh.Position(vertex + self:GetUp() * 190)
		mesh.TexCoord(0, width, height)
		mesh.AdvanceVertex()
		mesh.Position(vertex)
		mesh.TexCoord(0, width, 0)
		mesh.AdvanceVertex()
		mesh.End()
	end
end