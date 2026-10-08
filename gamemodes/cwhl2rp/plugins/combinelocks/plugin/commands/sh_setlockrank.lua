--- Registers the `/SetCombineLockRank` command, which lets Civil Protection of the CmD, SeC or MaJ rank close the
-- Combine lock they are looking at to a `/`-separated list of Combine ranks.

local COMMAND = cw.command:New('SetCombineLockRank')
COMMAND.tip = '#Command_Setcombinelockrank_Description'
COMMAND.text = '#Command_Setcombinelockrank_Syntax'
COMMAND.flags = bit.bor(CMD_DEFAULT, CMD_DEATHCODE)
COMMAND.arguments = 1

--- Restricts the Combine lock the player looks at to exclude the given ranks.
--
-- Only Civil Protection with the CmD, SeC or MaJ rank can use it, from within 192 units of the lock. The argument is a
-- list of up to 16 ranks separated by `/`, each made of letters and digits; an empty argument clears the restriction.
function COMMAND:OnRun(combine, arguments)
  if combine:GetFaction() != FACTION_MPF or !Schema:IsPlayerCombineRank(combine, { 'CmD', 'SeC', 'MaJ' }) then
    cw.player:Notify(combine, L('CombineLock_NoPermission'))

    return
  end

  local combinelock = combine:GetEyeTraceNoCursor().Entity

  if !IsValid(combinelock) or combinelock:GetClass() != 'cw_combinelock' then
    cw.player:Notify(combine, L('CombineLock_MustLookAt'))

    return
  end

  if combinelock:GetPos():Distance(combine:GetShootPos()) > 192 then
    cw.player:Notify(combine, L('CombineLock_NotCloseEnough'))

    return
  end

  local rank = {}

  -- The ranks end up in a Lua pattern that is matched against player names, so nothing but letters and digits may
  -- get through.
  for k, v in ipairs(string.Explode('/', arguments[1])) do
    if v != '' then
      if #rank >= 16 or #v > 16 or string.find(v, '%W') then
        cw.player:Notify(combine, L('CombineLock_InvalidRank'))

        return
      end

      rank[#rank + 1] = v
    end
  end

  if #rank == 0 then
    combinelock:SetCPRank(nil)
    cw.player:Notify(combine, L('CombineLock_RestrictionCleared'))

    return
  end

  combinelock:SetCPRank(rank)
  cw.player:Notify(combine, L('CombineLock_RestrictedFor')..' '..table.concat(rank, '/'))
end

COMMAND:Register()
