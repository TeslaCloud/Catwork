--- Shared definition of the `cw_salesman` entity, a non-spawnable `base_anim` entity named Salesman that removes its
-- chat bubble when it is removed.

ENT.Type = 'anim'
ENT.Base = 'base_anim'
ENT.Author = 'kurozael'
ENT.PrintName = 'Salesman'
ENT.Spawnable = false
ENT.AdminSpawnable = false

--- Removes the salesman's chat bubble on the server.
function ENT:OnRemove()
  if SERVER and IsValid(self.cwChatBubble) then
    self.cwChatBubble:Remove()
  end
end
