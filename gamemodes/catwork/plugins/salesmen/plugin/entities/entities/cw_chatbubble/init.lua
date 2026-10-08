--- Server-side code of the `cw_chatbubble` entity, which sets the speech bubble model and makes the entity non-solid
-- and immovable.

util.Include('shared.lua')

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

--- Sets the speech bubble model and makes the chat bubble non-solid and immovable.
function ENT:Initialize()
  self:SetModel('models/extras/info_speech.mdl')
  self:SetMoveType(MOVETYPE_NONE)
  self:SetSolid(SOLID_NONE)
end
