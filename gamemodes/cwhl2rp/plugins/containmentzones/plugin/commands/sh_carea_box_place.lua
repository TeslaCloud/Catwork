local COMMAND = cw.command:New('ContainmentBoxPlace')
COMMAND.tip = ''
COMMAND.text = '#Command_Containmentboxplace_Syntax'
COMMAND.flags = CMD_DEFAULT
COMMAND.access = 's'
COMMAND.arguments = 1

--- Adds a box containment zone between the player's start and end corners.
--
-- The first argument is the zone's radiation level. Clears the player's corners afterwards.
function COMMAND:OnRun(player, arguments)
  local trace = player:GetEyeTraceNoCursor()

  if player.cwRadSystemBoxInfo then
    if player.cwRadSystemBoxInfo.startpos then
      if player.cwRadSystemBoxInfo.endpos then
        cwRadSystem.stored[#cwRadSystem.stored + 1] = {
          pos1 = player.cwRadSystemBoxInfo.startpos,
          pos2 = player.cwRadSystemBoxInfo.endpos,
          rad = tonumber(arguments[1])
        }
      else
        cw.player:Notify(player, L('Containment_NoEndPos'))
        return
      end
    else
      cw.player:Notify(player, L('Containment_NoStartPos'))
      return
    end
  else
    cw.player:Notify(player, L('Containment_NoPos'))
    return
  end

  player.cwRadSystemBoxInfo = nil

  cw.player:Notify(player, L('Containment_BoxAdded', arguments[1]))
end

COMMAND:Register()
