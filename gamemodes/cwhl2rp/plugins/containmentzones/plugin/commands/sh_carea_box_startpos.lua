--- Registers the `/ContainmentBoxStartPos` superadmin command of the Radiation plugin, which sets the start corner of
-- the box containment zone being placed to where the player is looking.

local COMMAND = cw.command:New('ContainmentBoxStartPos')
COMMAND.tip = ''
COMMAND.text = ''
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 's'
COMMAND.arguments = 0

--- Sets the start corner of the box zone being placed to the position the player is looking at.
function COMMAND:OnRun(player, arguments)
  player.cwRadSystemBoxInfo = player.cwRadSystemBoxInfo or {}
  player.cwRadSystemBoxInfo.startpos = player:GetEyeTraceNoCursor().HitPos

  cw.player:Notify(player, L('Containment_StartPointSet'))
end

COMMAND:Register()
