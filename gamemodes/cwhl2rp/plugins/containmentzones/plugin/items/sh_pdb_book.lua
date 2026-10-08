--- Defines the PDB User Manual item (`pdb_book`) of the Radiation plugin, a book that raises the reader's Medical
-- attribute to 50 when it is lower, is not used up, and teaches Overwatch soldiers nothing.

ITEM.name = 'PDB User Manual'
ITEM.PrintName = '#Item_PdbBook_PrintName'
ITEM.uniqueID = 'pdb_book'
ITEM.cost = 0
ITEM.model = 'models/props_lab/binderredlabel.mdl'
ITEM.useText = '#Containment_UseText_Read'
ITEM.category = 'Literature'
ITEM.useSound = false
ITEM.weight = 0.5
ITEM.business = true
ITEM.description = '#Item_PdbBook_Description'

--- Raises the reader's Medical attribute to 50 if it is lower; the manual is kept.
--
-- Overwatch soldiers cannot learn from it.
function ITEM:OnUse(player, itemEntity)
  local atrs = player:GetAttributes()
  local medical = atrs[ATB_MEDICAL]

  if player:GetFaction() != FACTION_OTA then
    if medical then
      if tonumber(medical.amount) < 50 then
        player:UpdateAttribute(ATB_MEDICAL, 50 - tonumber(medical.amount))
        cw.player:Notify(player, L('Containment_Book_Learned'))
      else
        cw.player:Notify(player, L('Containment_Book_AlreadyKnown'))
      end
    end
  end

  return false
end

--- Called when the manual is dropped; does nothing, so it can be dropped freely.
function ITEM:OnDrop(player, position) end
