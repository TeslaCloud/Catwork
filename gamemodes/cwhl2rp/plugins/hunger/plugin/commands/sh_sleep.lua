local PLUGIN = PLUGIN

local COMMAND = cw.command:New('Sleep')
COMMAND.tip = '#Command_Sleep_Description'
COMMAND.text = '<none>'
COMMAND.flags = CMD_DEFAULT

--- Puts the player to sleep for 30 seconds and clears their fatigue, if it is at least 30.
function COMMAND:OnRun(player, arguments)
  if tonumber(player:GetCharacterData('Fatigue')) >= 30 then
    cw.player:SetRagdollState(player, RAGDOLL_KNOCKEDOUT, 30)
    player:SetCharacterData('Fatigue', 0)
  else
    cw.player:Notify(player, L('Hunger_TooAwakeToSleep'))
  end
end

COMMAND:Register()
